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

resource "azurerm_resource_group" "tanzu_resource_group" {
  name     = var.env_name
  location = var.location
}

resource "azurerm_resource_group" "network_resource_group" {
  name     = var.network_resource_group
  location = var.location
}

resource "azurerm_virtual_network" "tanzu_virtual_network" {
  name                = var.virtual_network
  depends_on          = [azurerm_resource_group.network_resource_group]
  resource_group_name = azurerm_resource_group.network_resource_group.name
  address_space       = var.tanzu_virtual_network_address_space
  location            = var.location
}

resource "azurerm_subnet" "infrastructure_subnet" {
  name                      = var.infrastructure_subnet
  depends_on                = [azurerm_resource_group.network_resource_group, azurerm_virtual_network.tanzu_virtual_network]
  resource_group_name       = azurerm_resource_group.network_resource_group.name
  virtual_network_name      = azurerm_virtual_network.tanzu_virtual_network.name
  address_prefixes          = var.tanzu_infrastructure_subnet
}

resource "azurerm_subnet" "services_subnet" {
  name                      = var.services_subnet
  depends_on                = [azurerm_resource_group.network_resource_group, azurerm_virtual_network.tanzu_virtual_network]
  resource_group_name       = azurerm_resource_group.network_resource_group.name
  virtual_network_name      = azurerm_virtual_network.tanzu_virtual_network.name
  address_prefixes          = var.tanzu_services_subnet
}

resource "azurerm_user_assigned_identity" "tkgi_master_identity" {
  name = var.azure_master_managed_identity
  resource_group_name = azurerm_resource_group.tanzu_resource_group.name
  location            = var.location
}

resource "azurerm_role_assignment" "master_role_assignemnt" {
  scope              = "${data.azurerm_subscription.primary.id}/resourceGroups/${var.env_name}"
  role_definition_name = "Contributor"
  principal_id       = azurerm_user_assigned_identity.tkgi_master_identity.principal_id
}

resource "azurerm_user_assigned_identity" "tkgi_worker_identity" {
  name = var.azure_worker_managed_identity
  resource_group_name = azurerm_resource_group.tanzu_resource_group.name
  location            = var.location
}

resource "azurerm_role_assignment" "worker_role_assignemnt" {
  scope              = "${data.azurerm_subscription.primary.id}/resourceGroups/${var.env_name}"
  role_definition_name = "Contributor"
  principal_id       = azurerm_user_assigned_identity.tkgi_worker_identity.principal_id
}

data "azurerm_subscription" "primary" {
}


# create linux jumpbox for installation
resource "azurerm_public_ip" "jumpbox_public_ip" {
    name                         = "${var.env_name}-jumpbox-public-ip"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.network_resource_group.name
    allocation_method            = "Static"
    idle_timeout_in_minutes      = 30
}
resource "azurerm_network_interface" "jumpbox_nic" {
    name                        = "${var.env_name}-jumpbox-nic"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.network_resource_group.name

    ip_configuration {
        name                          = "${var.env_name}-jumpbox-ip-config"
        subnet_id                     = azurerm_subnet.infrastructure_subnet.id
        private_ip_address_allocation = "static"
        private_ip_address            = var.jumpbox_private_ip
        public_ip_address_id          = azurerm_public_ip.jumpbox_public_ip.id
    }
}
resource "azurerm_network_security_group" "infrastructure_subnet_security_group" {
  name                = "${var.env_name}-infrastructure-subnet-security-group"
  location            = var.location
  resource_group_name = azurerm_resource_group.network_resource_group.name

  security_rule {
    name                       = "ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "https"
    priority                   = 205
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "jumpbox_nsg" {
    network_interface_id      = azurerm_network_interface.jumpbox_nic.id
    network_security_group_id = azurerm_network_security_group.infrastructure_subnet_security_group.id
}
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.network_resource_group.name
    }
    byte_length = 8
}
resource "azurerm_storage_account" "jumpbox_storage_account" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.network_resource_group.name
    location                    = var.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}
resource "tls_private_key" "jumpbox_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}
resource "azurerm_linux_virtual_machine" "jumpbox_vm" {
    name                  = "${var.env_name}-jumpbox"
    location              = var.location
    resource_group_name   = azurerm_resource_group.network_resource_group.name
    network_interface_ids = [azurerm_network_interface.jumpbox_nic.id]
    size                  = "Standard_DS1_v2"
    os_disk {
        name              = "${var.env_name}-jumpbox-disk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
    computer_name  = "jumpbox"
    admin_username = "ubuntu"
    disable_password_authentication = true
    admin_ssh_key {
        username       = "ubuntu"
        public_key     = tls_private_key.jumpbox_ssh_key.public_key_openssh
    }
    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.jumpbox_storage_account.primary_blob_endpoint
    }
}
