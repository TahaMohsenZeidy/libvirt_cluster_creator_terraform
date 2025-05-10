
# Define the list of my providers
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

# Configure the Libvirt providers
provider "libvirt" {
  uri = "qemu+ssh://${var.remote_host_username}@${var.cpu_optimized_host_remote_ip}/system"
  alias = "cpu_optimized_host"
}

provider "libvirt" {
  uri = "qemu+ssh://${var.remote_host_username}@${var.storage_optimized_host_1_remote_ip}/system" 
  alias = "storage_optimized_host_1"
}

provider "libvirt" {
  uri = "qemu+ssh://${var.remote_host_username}@${var.storage_optimized_host_2_remote_ip}/system"
  alias = "storage_optimized_host_2"
}

# Create the nodes on storage_optimized_host_1 which is chronos2
module "libvirt_vms_storage_optimized_host_1" {
  for_each = { for vm in var.vms_to_be_created_on_storage_optimized_host_1 : vm.vm_name => vm }
  providers = {
    libvirt = libvirt.storage_optimized_host_1
  }
  source = "./modules/libvirt_vm"
  # variables needed for outputing the ssh commands later
  remote_host_username = var.remote_host_username
  remote_host_ip = var.storage_optimized_host_1_remote_ip
  storage_pool = var.storage_pool
  vm_name = each.value.vm_name
  vm_public_ip = each.value.vm_public_ip
  vm_gateway = var.vm_gateway
  vm_dns = var.vm_dns
  public_ssh_key_file = var.public_ssh_key_file
  use_local_image = true
  use_public_ip = each.value.use_public_ip
  use_public_and_private = each.value.use_public_and_private
  base_image = var.base_image
  local_image_path = "/var/lib/libvirt/images_new/jammy-server-cloudimg-amd64.img"
  public_ip_bridge = var.public_ip_bridge
  private_ip_bridge = var.private_ip_bridge
  vm_username = var.remote_host_username
  vm_password = var.vms_password 
}

# create the nodes on storage_optimized_host_2 which is chronos0
module "libvirt_vms_storage_optimized_host_2" {
  for_each = { for vm in var.vms_to_be_created_on_storage_optimized_host_2 : vm.vm_name => vm }
  providers = {
    libvirt = libvirt.storage_optimized_host_2
  }
  source = "./modules/libvirt_vm" # This is the module that will be used to create the VMs  
  # variables needed for outputing the ssh commands later
  remote_host_username = var.remote_host_username
  remote_host_ip = var.storage_optimized_host_2_remote_ip
  storage_pool = var.storage_pool
  vm_name = each.value.vm_name
  vm_public_ip = each.value.vm_public_ip
  vm_gateway = var.vm_gateway
  vm_dns = var.vm_dns
  public_ssh_key_file = var.public_ssh_key_file
  use_local_image = true
  use_public_ip = each.value.use_public_ip
  use_public_and_private = each.value.use_public_and_private
  base_image = var.base_image
  local_image_path = var.local_image_path
  public_ip_bridge = var.public_ip_bridge
  private_ip_bridge = var.private_ip_bridge
  vm_username = var.remote_host_username
  vm_password = var.vms_password
}

# create the nodes on cpu_optimized_host which is chronos1
module "libvirt_vms_cpu_optimized_host" {
  for_each = { for vm in var.vms_to_be_created_on_cpu_optimized_host : vm.vm_name => vm }
  providers = {
    libvirt = libvirt.cpu_optimized_host
  }
  source = "./modules/libvirt_vm" # This is the module that will be used to create the VMs  
  # variables needed for outputing the ssh commands later 
  remote_host_username = var.remote_host_username
  remote_host_ip = var.cpu_optimized_host_remote_ip
  storage_pool = var.storage_pool
  vm_name = each.value.vm_name
  vm_public_ip = each.value.vm_public_ip
  vm_gateway = var.vm_gateway
  vm_dns = var.vm_dns
  public_ssh_key_file = var.public_ssh_key_file
  use_local_image = true
  use_public_ip = each.value.use_public_ip
  use_public_and_private = each.value.use_public_and_private
  base_image = var.base_image
  local_image_path = var.local_image_path
  public_ip_bridge = var.public_ip_bridge
  private_ip_bridge = var.private_ip_bridge
  vm_username = var.remote_host_username
  vm_password = var.vms_password
}

# Create an ansible inventory file for the VMs
resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    masters = concat(
      [for name, vm in module.libvirt_vms_storage_optimized_host_1 : "${vm.vm_name} ansible_host=${vm.vm_ip} ansible_user=${var.remote_host_username} ansible_ssh_common_args='-o ProxyJump=${var.remote_host_username}@${var.storage_optimized_host_1_remote_ip}'" if strcontains(vm.vm_name, "master")],
      [for name, vm in module.libvirt_vms_storage_optimized_host_2 : "${vm.vm_name} ansible_host=${vm.vm_ip} ansible_user=${var.remote_host_username} ansible_ssh_common_args='-o ProxyJump=${var.remote_host_username}@${var.storage_optimized_host_2_remote_ip}'" if strcontains(vm.vm_name, "master")],
      [for name, vm in module.libvirt_vms_cpu_optimized_host : "${vm.vm_name} ansible_host=${vm.vm_ip} ansible_user=${var.remote_host_username} ansible_ssh_common_args='-o ProxyJump=${var.remote_host_username}@${var.cpu_optimized_host_remote_ip}'" if strcontains(vm.vm_name, "master")]
    ),
    workers = concat(
      [for name, vm in module.libvirt_vms_storage_optimized_host_1 : "${vm.vm_name} ansible_host=${vm.vm_ip} ansible_user=${var.remote_host_username} ansible_ssh_common_args='-o ProxyJump=${var.remote_host_username}@${var.storage_optimized_host_1_remote_ip}'" if strcontains(vm.vm_name, "worker")],
      [for name, vm in module.libvirt_vms_storage_optimized_host_2 : "${vm.vm_name} ansible_host=${vm.vm_ip} ansible_user=${var.remote_host_username} ansible_ssh_common_args='-o ProxyJump=${var.remote_host_username}@${var.storage_optimized_host_2_remote_ip}'" if strcontains(vm.vm_name, "worker")],
      [for name, vm in module.libvirt_vms_cpu_optimized_host : "${vm.vm_name} ansible_host=${vm.vm_ip} ansible_user=${var.remote_host_username} ansible_ssh_common_args='-o ProxyJump=${var.remote_host_username}@${var.cpu_optimized_host_remote_ip}'" if strcontains(vm.vm_name, "worker")]
    )
  })
  filename = "${path.module}/inventory.ini"
}