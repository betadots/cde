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
    bridge   = optional(string)
    sshfs    = optional(object({
      user = optional(string)
      key_file = optional(string)
      mounts = optional(list(object({
        src = string
        dst = string
      })))
    }))
    openvox  = optional(string)
  })
  default = null
}

variable "vms" {
  type = map(object({
    template = optional(string)
    type     = optional(string)
    node     = optional(string)
    bridge   = optional(string)
    sshfs    = optional(object({
      user = optional(string)
      key_file = optional(string)
      mounts = optional(list(object({
        src = string
        dst = string
      })))
    }))
    openvox  = optional(string)
  }))
}

variable "types" {
  type = map
}
