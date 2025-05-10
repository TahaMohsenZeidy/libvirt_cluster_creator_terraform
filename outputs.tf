
# output all the ssh commands after creation from the module
output "ssh_commands_for_storage_optimized_host_1" {
  value = [for vm in module.libvirt_vms_storage_optimized_host_1 : vm.ssh_command]
  depends_on = [module.libvirt_vms_storage_optimized_host_1]
}

output "ssh_commands_for_storage_optimized_host_2" {
  value = [for vm in module.libvirt_vms_storage_optimized_host_2 : vm.ssh_command]
  depends_on = [module.libvirt_vms_storage_optimized_host_2]
}

output "ssh_commands_for_cpu_optimized_host" {
  value = [for vm in module.libvirt_vms_cpu_optimized_host : vm.ssh_command]
  depends_on = [module.libvirt_vms_cpu_optimized_host]
}

# output a message that the ansible inventory file has been created
output "ansible_inventory_file" {
  value = "The ansible inventory file has been created at ${path.module}/inventory.ini"
}