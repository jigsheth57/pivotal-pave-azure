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
  value = azurerm_user_assigned_identity.tkgi_master_identity.name
}
output "worker_managed_identity" {
  value = azurerm_user_assigned_identity.tkgi_worker_identity.name
}
output "network_resource_group" {
  value = azurerm_resource_group.network_resource_group.name
}
output "tanzu_resource_group_name" {
  value = azurerm_resource_group.tanzu_resource_group.name
}
output "network_name" {
  value = azurerm_virtual_network.tanzu_virtual_network.name
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
output "jumpbox_public_ip" {
  value = azurerm_public_ip.jumpbox_public_ip.ip_address
}
output "jumpbox_private_ip" {
  value = var.jumpbox_private_ip
}
output "jumpbox_ssh_public_key" {
  sensitive = true
  value     = tls_private_key.jumpbox_ssh_key.public_key_openssh
}
output "jumpbox_ssh_private_key" {
  sensitive = true
  value     = tls_private_key.jumpbox_ssh_key.private_key_pem
}
