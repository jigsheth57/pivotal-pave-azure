# ==================== Outputs

output "dns_name" {
  value = "${azurerm_dns_a_record.ops_manager_dns.name}.${azurerm_dns_a_record.ops_manager_dns.zone_name}"
}

output "ops_manager_private_ip" {
  value = var.ops_manager_private_ip
}

output "ops_manager_ssh_public_key" {
  sensitive = true
  value     = tls_private_key.ops_manager.public_key_openssh
}

output "ops_manager_ssh_private_key" {
  sensitive = true
  value     = tls_private_key.ops_manager.private_key_pem
}

output "ops_manager_storage_account" {
  value = azurerm_storage_account.ops_manager_storage_account.name
}
