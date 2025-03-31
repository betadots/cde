locals {
  templates = {
    for vm in data.proxmox_virtual_environment_vms.templates.vms:
    vm.name => {
      id   = vm.vm_id
      node = vm.node_name
    }
  }
}

variable "ssh" {
  type = map
}

variable "sshfs" {
  type = map
}

variable "name" {
  type = string
}

variable "template" {
  type = string
}

variable "node" {
  type = string
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "openvox" {
  type = string
  default = "8"
}
