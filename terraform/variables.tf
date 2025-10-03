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
    openvox = optional(object({
      collection       = optional(string)
      version          = optional(string)
      csr_attributes   = optional(object({
        extension_requests = optional(map(string), {})
        custom_attributes  = optional(map(string), {})
      }))
      prod_environment = optional(string)
    }), {})
  })
  default = null
}

variable "vms" {
  type = map(object({
    template  = optional(string)
    hostnamwe = optional(string)
    type      = optional(string)
    node      = optional(string)
    network   = optional(string)
    sshfs     = optional(object({
      user = optional(string)
      key_file = optional(string)
      mounts = optional(list(object({
        src = string
        dst = string
      })))
    }))
    openvox = optional(object({
      collection     = optional(string)
      version        = optional(string)
      csr_attributes = optional(object({
        extension_requests = optional(map(string), {})
        custom_attributes  = optional(map(string), {})
      }))
    }), {})
    provision = optional(list(object({
      name = string
      type = string
      args = optional(map(string))
    })))
  }))
}

variable "networks" {
  type = map
}

variable "types" {
  type = map
}
