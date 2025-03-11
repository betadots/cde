resource "proxmox_virtual_environment_vm" "this" {
  for_each    = var.vms

  name        = each.key
  description = "Managed by Terraform"
  node_name   = each.value.node

  clone {
    node_name = local.templates[each.value.template].node
    vm_id = local.templates[each.value.template].id
    full = false
  }

  cpu {
    cores = var.types[each.value.type].cores
    type  = "host"
  }

  memory {
    dedicated = var.types[each.value.type].memory
  }

  vga {
    memory = 16
    type   = "serial0"
  }

  network_device {
    bridge = "vmbr0"
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
    source      = var.sshfs.private
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
      #"sudo /tmp/terraform.sshfs -u ${var.sshfs.user} -h ${data.external.ip.result.v4} -s ${path.cwd}/.provision -d /terraform",
      "sudo /tmp/terraform.sshfs -u ${var.sshfs.user} -h ${local.myip} -s ${path.cwd}/.provision -d /terraform",
      #"sudo /tmp/terraform.sshfs -u ${var.sshfs.user} -h ${data.external.ip.result.v4} -s puppetcode -d /root/puppetcode",
      "sudo /tmp/terraform.sshfs -u ${var.sshfs.user} -h ${local.myip} -s puppetcode -d /root/puppetcode",
      "sudo /terraform/shell/openvox-agent.sh -v 8"
    ]
  }
}    
