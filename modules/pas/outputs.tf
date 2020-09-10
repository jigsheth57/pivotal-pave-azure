output "sys_domain" {
  value = "sys.${azurerm_dns_a_record.sys.zone_name}"
}

output "apps_domain" {
  value = "apps.${azurerm_dns_a_record.apps.zone_name}"
}

output "web_lb_name" {
  value = "${azurerm_lb.web-lb.name}"
}

output "diego_ssh_lb_name" {
  value = "${azurerm_lb.ssh-lb.name}"
}

# Subnets

output "services_subnet_name" {
  value = "${azurerm_subnet.services_subnet.name}"
}

output "services_subnet_cidr" {
  value = "${azurerm_subnet.services_subnet.address_prefix}"
}

output "services_subnet_gateway" {
  value = "${cidrhost(azurerm_subnet.services_subnet.address_prefix, 1)}"
}

# Storage

output "cf_storage_account_name" {
  value = "${azurerm_storage_account.cf_storage_account.name}"
}

output "cf_storage_account_access_key" {
  sensitive = true
  value     = "${azurerm_storage_account.cf_storage_account.primary_access_key}"
}

output "cf_droplets_storage_container_name" {
  value = "${azurerm_storage_container.cf_droplets_storage_container.name}"
}

output "cf_packages_storage_container_name" {
  value = "${azurerm_storage_container.cf_packages_storage_container.name}"
}

output "cf_resources_storage_container_name" {
  value = "${azurerm_storage_container.cf_resources_storage_container.name}"
}

output "cf_buildpacks_storage_container_name" {
  value = "${azurerm_storage_container.cf_buildpacks_storage_container.name}"
}

# Deprecated

output "services_subnet_cidrs" {
  value = ["${azurerm_subnet.services_subnet.address_prefix}"]
}
