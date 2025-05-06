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

  provisioner "file" {
    source      = var.sshfs.key_file
    destination = "/tmp/identity"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! $? -eq 0 ]; do sleep 5; cloud-init status --wait; done",
    ]
  }

  provisioner "local-exec" {
    command = "bolt plan run cde::provision openvox_collection=${var.openvox}  openvox_version='latest' sshfs_user=${var.sshfs.user} sshfs_host=${local.myip} --targets ${flatten(self.ipv4_addresses)[1]}"
  }
}    
