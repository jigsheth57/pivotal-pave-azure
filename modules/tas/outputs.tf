output "sys_domain" {
  value = "sys.${var.dns_subdomain}.${var.dns_suffix}"
#  value = "sys.${azurerm_dns_a_record.sys.zone_name}"
}

output "apps_domain" {
  value = "apps.${var.dns_subdomain}.${var.dns_suffix}"
#  value = "apps.${azurerm_dns_a_record.apps.zone_name}"
}

output "web_lb_name" {
  value = azurerm_lb.web-lb.name
}

output "diego_ssh_lb_name" {
  value = azurerm_lb.ssh-lb.name
}

# Storage

output "cf_storage_account_name" {
  value = azurerm_storage_account.cf_storage_account.name
}

output "cf_storage_account_access_key" {
  sensitive = true
  value     = azurerm_storage_account.cf_storage_account.primary_access_key
}

output "cf_droplets_storage_container_name" {
  value = azurerm_storage_container.cf_droplets_storage_container.name
}

output "cf_packages_storage_container_name" {
  value = azurerm_storage_container.cf_packages_storage_container.name
}

output "cf_resources_storage_container_name" {
  value = azurerm_storage_container.cf_resources_storage_container.name
}

output "cf_buildpacks_storage_container_name" {
  value = azurerm_storage_container.cf_buildpacks_storage_container.name
}
