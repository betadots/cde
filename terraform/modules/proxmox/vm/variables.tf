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
  type = object({
    user = string
    key_file = string
    mounts = list(object({
      src = string
      dst = string
    }))
  })
  default = null
}

variable "hostname" {
  type = string
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

variable "domain" {
  type    = string
}

variable "cores" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "provision" {
  type = map(object({
    type = string
    name = string
    args = optional(map(any))
  }))
}

variable "openvox" {
  type = string
  default = "8"
}

variable "openvox_prod_env" {
  type    = string
  default = ""
}
