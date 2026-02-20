output "debug_netbox" {
  value = data.netbox_virtual_machines.base_vm
}

output "vm_name" {
  value = local.vm_name
}

output "vm_cluster" {
  value = local.vm_cluster
}

output "vm_description" {
  value = local.vm_description
}

output "vm_cpu_type" {
  value = local.vm_cpu_type
}

output "vm_vcpus" {
  value = local.vm_vcpus
}

output "vm_memory" {
  value = local.vm_memory
}

output "vm_disk" {
  value = local.vm_disk_gb
}

output "vm_tag_names" {
  value = local.vm_tag_names
}

output "vm_ip4" {
  value = local.vm_ip4
}

