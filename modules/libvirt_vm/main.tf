terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

# Create cloud-init disk also the network config
resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "${var.vm_name}-commoninit.iso"
  pool      = var.storage_pool
  user_data = templatefile("${path.module}/templates/cloud_init.tftpl", {
    hostname = var.vm_name
    username = var.vm_username
    password = var.vm_password
    ssh_key  = var.vm_ssh_key != "" ? var.vm_ssh_key : file(pathexpand(var.public_ssh_key_file))
  })
  network_config = var.use_public_ip ? ( var.use_public_and_private ? templatefile("${path.module}/templates/network_config_both.tftpl", {
    ip      = var.vm_public_ip
    gateway = var.vm_gateway
    dns     = var.vm_dns
  }): 
  templatefile("${path.module}/templates/network_config_public.tftpl", {
    ip      = var.vm_public_ip
    gateway = var.vm_gateway
    dns     = var.vm_dns
  }) ) : templatefile("${path.module}/templates/network_config_private.tftpl", {})
}

# Fetch the base image from the Internet if you are not using a local image
resource "libvirt_volume" "ubuntu-qcow2" {
  count = var.use_local_image ? 0 : 1
  name   = "ubuntu-qcow2"
  pool   = var.storage_pool
  source = var.base_image
  format = "qcow2"
}

# Define the VM disk
resource "libvirt_volume" "vm_disk" {
  name           = "${var.vm_name}.qcow2"
  base_volume_id = var.use_local_image ? var.local_image_path : libvirt_volume.ubuntu-qcow2[0].id
  pool           = var.storage_pool
  size           = var.vm_disk_size * 1073741824  # Convert GB to bytes
}

# Define the VM
resource "libvirt_domain" "vm_domain" {
  name      = var.vm_name
  memory    = var.vm_ram * 1024
  vcpu      = var.vm_vcpus
  qemu_agent = true

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  # Add a private ip to the vm if no public ip is used
  dynamic "network_interface" {
    for_each = var.use_public_ip ? (var.use_public_and_private ? [1] : []) : [1]
    content {
      bridge = var.private_ip_bridge
      wait_for_lease = true
    }
  }

  # First network interface for public IP
  dynamic "network_interface" {
    for_each = var.use_public_ip ? [1] : []
    content {
      bridge = var.public_ip_bridge
    }
  }

  # Add console configuration
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }
}