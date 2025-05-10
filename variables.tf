# Define the variables to feed to the providers
variable "cpu_optimized_host_remote_ip" {
  type = string
}

variable "storage_optimized_host_1_remote_ip" {
  type = string
}

variable "storage_optimized_host_2_remote_ip" {
  type = string
}

variable "remote_host_username" {
  type = string
}

# Define the list of public IPs to use 
variable "master_vm_public_ip" {
  type = list(string)
}

# Define a variable to define all the VMs that will be created under storage_optimized_host_1
variable "vms_to_be_created_on_storage_optimized_host_1" {
  type = list(object({
    vm_name = string
    vm_public_ip = string
    use_public_ip = bool
    use_public_and_private = bool
  }))
}

# Define a variable to define all the VMs that will be created under storage_optimized_host_2
variable "vms_to_be_created_on_storage_optimized_host_2" {
  type = list(object({
    vm_name = string
    vm_public_ip = string
    use_public_ip = bool
    use_public_and_private = bool
  }))
}

# Define a variable to define all the VMs that will be created under cpu_optimized_host
variable "vms_to_be_created_on_cpu_optimized_host" {
  type = list(object({
    vm_name = string
    vm_public_ip = string
    use_public_ip = bool
    use_public_and_private = bool
  }))
}

variable "vms_password" {
  type = string
}

variable "storage_pool" {
  type = string
}

variable "vm_gateway" {
  type = string
}

variable "vm_dns" {
  type = string
}

variable "public_ssh_key_file" {
  type = string
}

variable "base_image" {
  type = string
}

variable "local_image_path" {
  type = string
}

variable "public_ip_bridge" {
  type = string
}

variable "private_ip_bridge" {
  type = string
}

