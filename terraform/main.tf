module "pve_vm" {
  for_each = local.vms

  source = "./modules/proxmox/vm"

  name      = each.key
  node      = each.value.node
  template  = each.value.template
  cores     = var.types[each.value.type].cores
  memory    = var.types[each.value.type].memory
  bridge    = try(var.networks[each.value.network].bridge, "vmbr0")
  domain    = var.networks[each.value.network].domain
  ssh       = {
    user       = "cloud"
    public_key = file(var.ssh.public_key)
  }
  sshfs     = each.value.sshfs
  provision = each.value.provision
  openvox   = each.value.openvox
  openvox_prod_env  = each.value.openvox_prod_env
}
