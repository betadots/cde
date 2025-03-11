data "proxmox_virtual_environment_nodes" "nodes" {}

data "proxmox_virtual_environment_vms" "templates" {
  filter {
    name = "template"
    regex = true
    values = [true]
  }
}

data "external" "ip" {
  program = ["bash", "${path.module}/get_ipaddr.sh"]
}

data "external" "local" {
  program = ["facter", "networking.ip", "--json"]
}
