# resource "azurerm_dns_a_record" "ops_manager_dns" {
#   name                = "opsman"
#   zone_name           = var.dns_zone_name
#   resource_group_name = var.resource_group_name
#   ttl                 = "60"
#   records             = [var.ops_manager_private_ip]
# }
