terraform {
  required_version = "~> 0.13.0"
  required_providers {
    azurerm = {
      version = "~> 2.31.0"
    }
    tls = {
      version = "~> 2.2.0"
      source = "hashicorp/tls"
    }
    random = {
      version = "~> 3.0.0"
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  environment     = var.cloud_name

  features {}
}

module "infra" {
  source = "../modules/infra"

  env_name                          = var.env_name
  location                          = var.location
  dns_subdomain                     = var.dns_subdomain
  dns_suffix                        = var.dns_suffix
  pcf_infrastructure_subnet         = var.pcf_infrastructure_subnet
  pcf_virtual_network_address_space = var.pcf_virtual_network_address_space
  # virtual_network                   = var.virtual_network
}

module "ops_manager" {
  source = "../modules/ops_manager"

  env_name = var.env_name
  location = var.location

  ops_manager_image_uri  = var.ops_manager_image_uri
  ops_manager_vm_size    = var.ops_manager_vm_size
  ops_manager_private_ip = var.ops_manager_private_ip

  resource_group_name = module.infra.resource_group_name
  dns_zone_name       = module.infra.dns_zone_name
  security_group_id   = module.infra.security_group_id
  subnet_id           = module.infra.infrastructure_subnet_id
}

module "pas" {
  source = "../modules/pas"

  env_id   = var.env_name
  env_name = var.env_name
  location = var.location

  services_subnet_cidr = var.pcf_services_subnet

  cf_storage_account_name              = var.cf_storage_account_name
  cf_buildpacks_storage_container_name = var.cf_buildpacks_storage_container_name
  cf_droplets_storage_container_name   = var.cf_droplets_storage_container_name
  cf_packages_storage_container_name   = var.cf_packages_storage_container_name
  cf_resources_storage_container_name  = var.cf_resources_storage_container_name
  ssh_lb_private_ip = var.ssh_lb_private_ip
  web_lb_private_ip = var.web_lb_private_ip

  resource_group_name                 = module.infra.resource_group_name
  dns_zone_name                       = module.infra.dns_zone_name
  network_name                        = module.infra.network_name
  bosh_deployed_vms_security_group_id = module.infra.bosh_deployed_vms_security_group_id
  infra_subnet_id = module.infra.infrastructure_subnet_id
}

module "certs" {
  source = "../modules/certs"

  env_name           = var.env_name
  dns_suffix         = var.dns_suffix
  ssl_ca_cert        = var.ssl_ca_cert
  ssl_ca_private_key = var.ssl_ca_private_key
}

module "pks" {
  source = "../modules/pks"

  env_id   = var.env_name
  location = var.location
  services_subnet_cidr = var.pcf_services_subnet
  infrastructure_subnet_cidr = var.pcf_infrastructure_subnet
  harbor_lb_private_ip = var.harbor_lb_private_ip
  pks_lb_private_ip = var.pks_lb_private_ip

  resource_group_cidr = var.pcf_virtual_network_address_space[0]

  resource_group_name                 = module.infra.resource_group_name
  dns_zone_name                       = module.infra.dns_zone_name
  network_name                        = module.infra.network_name
  bosh_deployed_vms_security_group_id = module.infra.bosh_deployed_vms_security_group_id
  infra_subnet_id = module.infra.infrastructure_subnet_id
}

data "azurerm_subscription" "primary" {
}

data "azurerm_resource_group" "primary" {
  name     = "${var.env_name}"
}

resource "azurerm_availability_set" "pks" {
  name                = "${var.env_name}-availability-set"
  location            = var.location
  resource_group_name = module.infra.resource_group_name
}
