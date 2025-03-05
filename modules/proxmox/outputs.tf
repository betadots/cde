output "templates" {
  value = data.proxmox_virtual_environment_vms.templates
}

output "ipv4" {
  value = {
    for k, v in proxmox_virtual_environment_vm.this:
    k => flatten(v.ipv4_addresses)[1]
  }
}
