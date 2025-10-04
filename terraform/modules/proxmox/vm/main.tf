resource "proxmox_virtual_environment_vm" "this" {
  name        = var.hostname
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

    dns {
      domain = var.domain
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

  provisioner "file" {
    # require connection
    source      = var.sshfs.key_file
    destination = "/tmp/identity"
  }

  provisioner "local-exec" {
    command = var.openvox == null ? "exit 0": "bolt plan run cde::openvox %{ if var.openvox.collection != null }collection=${var.openvox.collection}%{ endif } %{ if var.openvox.version != null }version=${var.openvox.version}%{ endif } %{ if var.openvox.prod_environment != null }prod_environment=${var.openvox.prod_environment}%{ endif } %{ if var.openvox.csr_attributes != null }csr_attributes='${jsonencode(var.openvox.csr_attributes)}'%{ endif } targets=${flatten(self.ipv4_addresses)[1]}"
  }

  provisioner "local-exec" {
    command = var.sshfs.mounts == null ? "exit 0" : "bolt plan run cde::mount targets=${flatten(proxmox_virtual_environment_vm.this.ipv4_addresses)[1]} sshfs_user=${var.sshfs.user} sshfs_host=${local.myip} mounts='${jsonencode(var.sshfs.mounts)}'"
  }

  #provisioner "local-exec" {
  #  command = var.provision == null ? "exit 0": "bolt plan run cde::dispatch targets=${flatten(self.ipv4_addresses)[1]} scripts='${jsonencode(values(var.provision))}'"
  #}
}    
