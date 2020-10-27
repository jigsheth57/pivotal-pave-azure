output "iaas" {
  value = "azure"
}
output "location" {
  value     = var.location
}
output "subscription_id" {
  sensitive = true
  value     = var.subscription_id
}
output "tenant_id" {
  sensitive = true
  value     = var.tenant_id
}
output "client_id" {
  sensitive = true
  value     = var.client_id
}
output "client_secret" {
  sensitive = true
  value     = var.client_secret
}
output "master_managed_identity" {
  value = var.azure_master_managed_identity
}
output "worker_managed_identity" {
  value = var.azure_worker_managed_identity
}
output "network_resource_group" {
  value = var.network_resource_group
}
output "pcf_resource_group_name" {
  value = var.env_name
}
output "network_name" {
  value = azurerm_virtual_network.pcf_virtual_network.name
}
output "infrastructure_subnet_name" {
  value = azurerm_subnet.infrastructure_subnet.name
}
output "infrastructure_subnet_cidr" {
  value = azurerm_subnet.infrastructure_subnet.address_prefix
}
output "infrastructure_subnet_gateway" {
  value = cidrhost(azurerm_subnet.infrastructure_subnet.address_prefix, 1)
}
output "services_subnet_name" {
  value = azurerm_subnet.services_subnet.name
}
output "services_subnet_cidr" {
  value =azurerm_subnet.services_subnet.address_prefix
}
output "services_subnet_gateway" {
  value = cidrhost(azurerm_subnet.services_subnet.address_prefix, 1)
}
