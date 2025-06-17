variable "proxmox" {
  type = map
}

variable "ssh" {
  type = map
}

variable "vm_default" {
  type = object({
    template = optional(string)
    type     = optional(string)
    node     = optional(string)
    network  = optional(string)
    sshfs    = optional(object({
      user = optional(string)
      key_file = optional(string)
      mounts = optional(list(object({
        src = string
        dst = string
      })))
    }))
    openvox          = optional(string)
    openvox_prod_env = optional(string)
  })
  default = null
}

variable "vms" {
  type = map(object({
    template = optional(string)
    type     = optional(string)
    node     = optional(string)
    network  = optional(string)
    sshfs    = optional(object({
      user = optional(string)
      key_file = optional(string)
      mounts = optional(list(object({
        src = string
        dst = string
      })))
    }))
    provision        = optional(list(object({
      name = string
      type = string
      args = optional(map(string))
    })))
    openvox          = optional(string)
    openvox_prod_env = optional(string)
  }))
}

variable "networks" {
  type = map
}

variable "types" {
  type = map
}
