locals {
  list = { for vm in data.proxmox_virtual_environment_vms.list.vms:
    vm.name => vm.status if ! vm.template
  }
  status = { for vm in keys(var.vms):
    vm => contains(keys(local.list), vm) ? local.list[vm] : "absent"
  }
}
