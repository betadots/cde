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

  provisioner "file" {
    source      = "${path.root}/.provision/sshfs.sh"
    destination = "/tmp/terraform.sshfs"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo install -o root -g root -m700 -d  /root/.ssh",
      "sudo install -o root -g root -m600 /tmp/identity /root/.ssh/identity && rm /tmp/identity",
      "sudo chmod +x /tmp/terraform.sshfs",
      "sudo /tmp/terraform.sshfs -u ${var.sshfs.user} -h ${local.myip} -s ${path.cwd}/.provision -d /terraform",
      "sudo /tmp/terraform.sshfs -u ${var.sshfs.user} -h ${local.myip} -s puppetcode -d /root/puppetcode",
#      "sudo /terraform/shell/openvox-agent.sh -v 8"
    ]
  }

  provisioner "local-exec" {
    command = "bolt task run cde::install_openvox --targets ${var.name}"
  } 

#  provisioner "local-exec" {
#    command = "bolt apply -e \"file { '/tmp/bolt.txt': ensure => file, content => 'Test' }\" --targets ${each.key}"
#  } 
}    
