terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~>0.71.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  api_token = var.proxmox.api_token
  insecure = true
}
