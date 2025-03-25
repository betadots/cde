data "proxmox_virtual_environment_vms" "list" {
  filter {
    name = "name"
    regex = true
    values = keys(var.vms)
  }
}
