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
# Output from infra module
output "dns_subdomain" {
  value = module.infra.dns_zone_name
}
output "env_dns_zone_name_servers" {
  value = module.infra.dns_zone_name_servers
}
output "tanzu_resource_group_name" {
  value = module.infra.resource_group_name
}
output "network_name" {
  value = module.infra.network_name
}
output "infrastructure_subnet_name" {
  value = module.infra.infrastructure_subnet_name
}
output "infrastructure_subnet_cidr" {
  value = module.infra.infrastructure_subnet_cidr
}
output "infrastructure_subnet_gateway" {
  value = module.infra.infrastructure_subnet_gateway
}
output "infrastructure_subnet_reserved_ip_range" {
  value = var.infrastructure_subnet_reserved_ip_range
}
output "services_subnet_name" {
  value = module.infra.services_subnet_name
}
output "services_subnet_cidr" {
  value = module.infra.services_subnet_cidr
}
output "services_subnet_gateway" {
  value = module.infra.services_subnet_gateway
}
output "services_subnet_reserved_ip_range" {
  value = var.services_subnet_reserved_ip_range
}
output "ops_manager_security_group_name" {
  value = module.infra.infrastructure_subnet_security_group_name
}
output "bosh_deployed_vms_security_group_name" {
  value = module.infra.services_subnet_security_group_name
}
output "bosh_root_storage_account" {
  value = module.infra.bosh_root_storage_account
}

# Output from ops_manager module
output "ops_manager_dns" {
  value = module.ops_manager.dns_name
}
output "ops_manager_private_ip" {
  value = module.ops_manager.ops_manager_private_ip
}
output "ops_manager_ssh_public_key" {
  sensitive = true
  value     = module.ops_manager.ops_manager_ssh_public_key
}
output "ops_manager_ssh_private_key" {
  sensitive = true
  value     = module.ops_manager.ops_manager_ssh_private_key
}
output "ops_manager_storage_account" {
  value = module.ops_manager.ops_manager_storage_account
}

# Output from tas module
output "sys_domain" {
  value = module.tas.sys_domain
}
output "apps_domain" {
  value = module.tas.apps_domain
}
output "web_lb_name" {
  value = module.tas.web_lb_name
}
output "diego_ssh_lb_name" {
  value = module.tas.diego_ssh_lb_name
}
output "cf_storage_account_name" {
  value = module.tas.cf_storage_account_name
}
output "cf_storage_account_access_key" {
  sensitive = true
  value     = module.tas.cf_storage_account_access_key
}
output "cf_droplets_storage_container" {
  value = module.tas.cf_droplets_storage_container_name
}
output "cf_packages_storage_container" {
  value = module.tas.cf_packages_storage_container_name
}
output "cf_resources_storage_container" {
  value = module.tas.cf_resources_storage_container_name
}
output "cf_buildpacks_storage_container" {
  value = module.tas.cf_buildpacks_storage_container_name
}

# Output from tkgi module
output "tkgi_lb_name" {
  value = module.tkgi.tkgi_lb_name
}
output "tkgi_api_hostname" {
  value = module.tkgi.tkgi_api_hostname
}
output "harbor_lb_name" {
  value = module.tkgi.harbor_lb_name
}
output "harbor_hostname" {
  value = module.tkgi.harbor_hostname
}
output "tkgi_availability_set" {
  value = module.tkgi.tkgi_availability_set
}

# Output from certs module
output "ssl_cert" {
  sensitive = true
  value     = length(module.certs.ssl_cert) > 0 ? module.certs.ssl_cert : var.ssl_cert
}
output "ssl_private_key" {
  sensitive = true
  value     = length(module.certs.ssl_private_key) > 0 ? module.certs.ssl_private_key : var.ssl_private_key
}
