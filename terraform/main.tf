module "pve_vm" {
  for_each = var.vms

  source   = "./modules/proxmox/vm"

  name     = each.key
  node     = each.value.node
  template = each.value.template
  cores    = var.types[each.value.type].cores
  memory   = var.types[each.value.type].memory
  ssh      = {
    user       = var.ssh.user
    public_key = file(var.ssh.public_key)
  }
  sshfs    = var.sshfs
  openvox  = var.openvox
}
