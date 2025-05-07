output "ipv4" {
  value = {
    for k, v in module.pve_vm:
    k => v.ipv4
  }
}

output "status" {
  value = local.status
}
