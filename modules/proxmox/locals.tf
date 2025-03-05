locals {
  templates = {
    for vm in data.proxmox_virtual_environment_vms.templates.vms:
    vm.name => {
      id   = vm.vm_id
      node = vm.node_name
    }
  }
}
