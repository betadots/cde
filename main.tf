module "proxmox" {
  source = "./modules/proxmox"

  ssh    = {
    user       = "lbetz"
    public_key = file("~/.ssh/id_ed25519.pub")
  }

  sshfs  = {
    user    = "lbetz"
    private = "~/.ssh/id_ed25519.terraform"
  }

  vms    = var.vms
  types  = var.types
}
