# cluster-terraform
Using the libvirt terraform provider, I will automate the creation of VMs to build in a later stage a Kubernetes cluster.


![Terraform Libvirt Flow](multiple-vm_terraform.png)


To get Started I advice you to take a look at this repo (it's from where I created the VM module)
[terraform-libvirt-vm](https://github.com/TahaMohsenZeidy/libvirt-vm-creator-terraform.git)
Also the same prerequisites apply here

what you need to do is to modify terraform.tfvars and also main.tf if you want to change the VMs that will be created.

I will be using the following VMs

the inventory file will be created in the root of the project inventory.ini

we will create a new ansible project to setup a kubernetes cluster


