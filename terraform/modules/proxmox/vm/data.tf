data "proxmox_virtual_environment_vms" "templates" {
  filter {
    name = "template"
    regex = true
    values = [true]
  }
}

data "external" "local" {
  program = ["facter", "networking.ip", "--json"]
}
