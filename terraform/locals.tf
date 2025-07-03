locals {
  list = { for vm in data.proxmox_virtual_environment_vms.list.vms:
    vm.name => vm.status if ! vm.template
  }
  status = { for vm in keys(var.vms):
    vm => contains(keys(local.list), vm) ? local.list[vm] : "absent"
  }
  vms = {
    for k,v in var.vms:
    k => {
      template = try(v.template, null) != null ? v.template : try(var.vm_default.template, null)
      type     = try(v.type, null) != null ? v.type : try(var.vm_default.type, null)
      node     = try(v.node, null) != null ? v.node : try(var.vm_default.node, null)
      network  = try(v.network, null) != null ? v.network : try(var.vm_default.network, null)
      sshfs    = {
        user = try(v.sshfs.user, null) != null ? v.sshfs.user : try(var.vm_default.sshfs.user, null)
        key_file = try(v.sshfs.key_file, null) != null ? v.sshfs.key_file : try(var.vm_default.sshfs.key_file, null)
        mounts = try(v.sshfs.mounts, null) != null ? v.sshfs.mounts : try(var.vm_default.sshfs.mounts, null)
      }
      provision =  merge(v.provision == null ? {} : {
        for i in v.provision:
          i.name => i
        }, {
        "cde::dhcp_client" = {
          type = "plan"
          name = "cde::dhcp_client"
          args = { my_domain = try(v.network, null) != null ? var.networks[v.network].domain : try(var.networks[var.vm_default.network].domain, "") }
        }
      })
      openvox   = try(v.openvox, null) != null ? v.openvox : try(var.vm_default.openvox, null)
      openvox_prod_env   = try(v.openvox_prod_env, null) != null ? v.openvox_prod_env : try(var.vm_default.openvox_prod_env, "")
    }
  }
}
