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

resource "azurerm_resource_group" "pcf_resource_group" {
  name     = "${var.env_name}"
  location = "${var.location}"
}

resource "azurerm_resource_group" "network_resource_group" {
  name     = "${var.network_resource_group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "pcf_virtual_network" {
  name                = "${var.network_resource_group}-virtual-network"
  depends_on          = [azurerm_resource_group.network_resource_group]
  resource_group_name = azurerm_resource_group.network_resource_group.name
  address_space       = "${var.pcf_virtual_network_address_space}"
  location            = "${var.location}"
}

resource "azurerm_subnet" "infrastructure_subnet" {
  name                      = "${var.network_resource_group}-infrastructure-subnet"
  depends_on                = [azurerm_resource_group.network_resource_group, azurerm_virtual_network.pcf_virtual_network]
  resource_group_name       = azurerm_resource_group.network_resource_group.name
  virtual_network_name      = azurerm_virtual_network.pcf_virtual_network.name
  address_prefix            = "${var.pcf_infrastructure_subnet}"
}

resource "azurerm_subnet" "services_subnet" {
  name                      = "${var.network_resource_group}-services-subnet"
  depends_on                = [azurerm_resource_group.network_resource_group, azurerm_virtual_network.pcf_virtual_network]
  resource_group_name       = azurerm_resource_group.network_resource_group.name
  virtual_network_name      = azurerm_virtual_network.pcf_virtual_network.name
  address_prefix            = "${var.pcf_services_subnet}"
}

resource "azurerm_user_assigned_identity" "pks_master_identity" {
  name = "${var.azure_master_managed_identity}"
  resource_group_name = azurerm_resource_group.pcf_resource_group.name
  location            = var.location
}

resource "azurerm_role_assignment" "master_role_assignemnt" {
  scope              = "${data.azurerm_subscription.primary.id}/resourceGroups/${var.env_name}"
  role_definition_name = "Contributor"
  principal_id       = azurerm_user_assigned_identity.pks_master_identity.principal_id
}

resource "azurerm_user_assigned_identity" "pks_worker_identity" {
  name = "${var.azure_worker_managed_identity}"
  resource_group_name = azurerm_resource_group.pcf_resource_group.name
  location            = var.location
}

resource "azurerm_role_assignment" "worker_role_assignemnt" {
  scope              = "${data.azurerm_subscription.primary.id}/resourceGroups/${var.env_name}"
  role_definition_name = "Contributor"
  principal_id       = azurerm_user_assigned_identity.pks_worker_identity.principal_id
}

data "azurerm_subscription" "primary" {
}
