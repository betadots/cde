output "templates" {
  value = {
    for instance in data.proxmox_virtual_environment_vms.templates.vms:
    instance.name => {
      id = instance.vm_id
      node = instance.node_name
    }
  }
}

output "ipv4" {
  value = {
    for k, v in proxmox_virtual_environment_vm.this:
    k => flatten(v.ipv4_addresses)[1]
  }
}
