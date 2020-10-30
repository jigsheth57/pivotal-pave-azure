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

  env_name                              = var.env_name
  location                              = var.location
#  dns_subdomain                         = var.dns_subdomain
#  dns_suffix                            = var.dns_suffix
  network_resource_group                = var.network_resource_group
  virtual_network                       = var.virtual_network
  infrastructure_subnet                 = var.infrastructure_subnet
  services_subnet                       = var.services_subnet
}

module "ops_manager" {
  source = "../modules/ops_manager"

  env_name      = var.env_name
  location      = var.location
  dns_subdomain = var.dns_subdomain
  dns_suffix    = var.dns_suffix

  ops_manager_image_uri  = var.ops_manager_image_uri
  ops_manager_vm_size    = var.ops_manager_vm_size
  ops_manager_private_ip = var.ops_manager_private_ip

  resource_group_name = module.infra.resource_group_name
#  dns_zone_name       = module.infra.dns_zone_name
  security_group_id   = module.infra.infrastructure_subnet_security_group_id
  subnet_id           = module.infra.infrastructure_subnet_id
}

module "tas" {
  source = "../modules/tas"

  env_name                              = var.env_name
  location                              = var.location
  dns_subdomain                         = var.dns_subdomain
  dns_suffix                            = var.dns_suffix

  cf_storage_account_name               = var.cf_storage_account_name
  cf_buildpacks_storage_container_name  = var.cf_buildpacks_storage_container_name
  cf_droplets_storage_container_name    = var.cf_droplets_storage_container_name
  cf_packages_storage_container_name    = var.cf_packages_storage_container_name
  cf_resources_storage_container_name   = var.cf_resources_storage_container_name
  ssh_lb_private_ip                     = var.ssh_lb_private_ip
  web_lb_private_ip                     = var.web_lb_private_ip

  resource_group_name                   = module.infra.resource_group_name
#  dns_zone_name                         = module.infra.dns_zone_name
  infra_subnet_id                       = module.infra.infrastructure_subnet_id
}

module "certs" {
  source = "../modules/certs"

  dns_subdomain      = var.dns_subdomain
  dns_suffix         = var.dns_suffix
  ssl_ca_cert        = var.ssl_ca_cert
  ssl_ca_private_key = var.ssl_ca_private_key
}

module "tkgi" {
  source = "../modules/tkgi"

  env_name                = var.env_name
  location                = var.location
  dns_subdomain           = var.dns_subdomain
  dns_suffix              = var.dns_suffix
  harbor_lb_private_ip    = var.harbor_lb_private_ip
  tkgi_lb_private_ip      = var.tkgi_lb_private_ip

  resource_group_name     = module.infra.resource_group_name
#  dns_zone_name           = module.infra.dns_zone_name
  infra_subnet_id         = module.infra.infrastructure_subnet_id
}
