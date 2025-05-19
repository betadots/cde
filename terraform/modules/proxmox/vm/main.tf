resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = "Managed by Terraform"
  node_name   = var.node

  clone {
    node_name = local.templates[var.template].node
    vm_id = local.templates[var.template].id
    full = false
  }

  cpu {
    cores = var.cores
    type  = "host"
  }

  memory {
    dedicated = var.memory
  }

  vga {
    memory = 16
    type   = "serial0"
  }

  network_device {
    bridge = var.bridge
    mtu = 1
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    
    user_account {
      username = var.ssh.user
      keys     = [ trimspace(var.ssh.public_key) ]
    }
  }

  connection {
    type     = "ssh"
    user     = var.ssh.user
    host     = flatten(self.ipv4_addresses)[1]
  }

  provisioner "remote-exec" {
    # require connection
    inline = [
      "while [ ! $? -eq 0 ]; do sleep 1; cloud-init status --wait; done",
    ]
  }

  provisioner "local-exec" {
    command = "bolt task run cde::install_agent collection=openvox${var.openvox} version='latest' stop_service=true --targets ${flatten(self.ipv4_addresses)[2]}"
  }
}    

resource "null_resource" "this" {
  count = var.sshfs != null ? 1 : tonumber("0")

  connection {
    type     = "ssh"
    user     = var.ssh.user
    host     = flatten(proxmox_virtual_environment_vm.this.ipv4_addresses)[1]
  }

  provisioner "file" {
    # require connection
    source      = var.sshfs.key_file
    destination = "/tmp/identity"
  }

  provisioner "local-exec" {
    command = var.sshfs.mounts == null ? "exit 0" : "bolt plan run cde::mount targets=${flatten(proxmox_virtual_environment_vm.this.ipv4_addresses)[1]} sshfs_user=${var.sshfs.user} sshfs_host=${local.myip} mounts='${jsonencode(var.sshfs.mounts)}'"
  }
}
