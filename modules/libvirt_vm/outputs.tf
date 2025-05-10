output vm_name {
  value       = libvirt_domain.vm_domain.name
  description = "the name you gave to your domain"
  depends_on  = [libvirt_domain.vm_domain]
}

# output the private ip of the vm (always)
output vm_ip {
  value = try(
    libvirt_domain.vm_domain.network_interface[0].addresses[0],
    "${var.vm_public_ip}"
  )
  description = "the produced ip address"
  depends_on  = [libvirt_domain.vm_domain]
}

output ssh_command {
  value       = var.use_public_ip ? "to ssh into ${var.vm_name}, run: ssh ${var.vm_username}@${var.vm_public_ip}" : "to ssh into ${var.vm_name}, run: ssh ${var.vm_username}@${libvirt_domain.vm_domain.network_interface.0.addresses[0]} -J ${var.remote_host_username}@${var.remote_host_ip}"
  description = "description"
  depends_on  = [libvirt_domain.vm_domain]
}
