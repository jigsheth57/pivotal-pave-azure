output "dns_zone_name" {
  value = azurerm_dns_zone.env_dns_zone.name
}

output "dns_zone_name_servers" {
  value = azurerm_dns_zone.env_dns_zone.name_servers
}

output "resource_group_name" {
  value = data.azurerm_resource_group.pcf_resource_group.name
}

output "network_name" {
  value = data.azurerm_virtual_network.pcf_virtual_network.name
}

output "infrastructure_subnet_id" {
  value = data.azurerm_subnet.infrastructure_subnet.id
}

output "infrastructure_subnet_name" {
  value = data.azurerm_subnet.infrastructure_subnet.name
}

output "infrastructure_subnet_cidr" {
  value = data.azurerm_subnet.infrastructure_subnet.address_prefix
}

output "infrastructure_subnet_gateway" {
  value = cidrhost(data.azurerm_subnet.infrastructure_subnet.address_prefix, 1)
}

output "infrastructure_subnet_security_group_name" {
  value = azurerm_network_security_group.infrastructure_subnet_security_group.name
}

output "infrastructure_subnet_security_group_id" {
  value = azurerm_network_security_group.infrastructure_subnet_security_group.id
}

output "services_subnet_id" {
  value = data.azurerm_subnet.services_subnet.id
}

output "services_subnet_name" {
  value = data.azurerm_subnet.services_subnet.name
}

output "services_subnet_cidr" {
  value = data.azurerm_subnet.services_subnet.address_prefix
}

output "services_subnet_gateway" {
  value = cidrhost(data.azurerm_subnet.services_subnet.address_prefix, 1)
}

output "services_subnet_security_group_name" {
  value = azurerm_network_security_group.services_subnet_security_group.name
}

output "services_subnet_security_group_id" {
  value = azurerm_network_security_group.services_subnet_security_group.id
}

output "bosh_root_storage_account" {
  value = azurerm_storage_account.bosh_root_storage_account.name
}
