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
  value = flatten(proxmox_virtual_environment_vm.this.ipv4_addresses)[1]
}
