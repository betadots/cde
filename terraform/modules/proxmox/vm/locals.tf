locals {
  myip = data.external.local.result["networking.ip"]

#  provision = merge({
#    "cde::dhcp_client" = {
#      type = "plan"
#      args = { my_domain = var.domain }
#    }
#  }, var.provision == null ? {} : {
#    for i in var.provision:
#      i.name => i
#  })
}
