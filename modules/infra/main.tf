data "azurerm_resource_group" "pcf_resource_group" {
  name     = var.env_name
}

data "azurerm_resource_group" "network_resource_group" {
  name     = var.network_resource_group
}

data "azurerm_virtual_network" "pcf_virtual_network" {
  name                = var.virtual_network
  resource_group_name = data.azurerm_resource_group.network_resource_group.name
}

data "azurerm_subnet" "infrastructure_subnet" {
  name                 = var.infrastructure_subnet
  virtual_network_name = data.azurerm_virtual_network.pcf_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.network_resource_group.name
}

data "azurerm_subnet" "services_subnet" {
  name                 = var.services_subnet
  virtual_network_name = data.azurerm_virtual_network.pcf_virtual_network.name
  resource_group_name  = data.azurerm_resource_group.network_resource_group.name
}

# ============== Security Groups ===============

resource "azurerm_network_security_group" "infrastructure_subnet_security_group" {
  name                = "${var.env_name}-infrastructure-subnet-security-group"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.pcf_resource_group.name

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

resource "azurerm_network_security_group" "services_subnet_security_group" {
  name                = "${var.env_name}-services-subnet-security-group"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.pcf_resource_group.name

  security_rule {
    name                       = "internal-anything"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "dns"
    priority                   = 203
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = 53
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "infrastructure_subnet_security_group" {
  subnet_id                 = data.azurerm_subnet.infrastructure_subnet.id
  network_security_group_id = azurerm_network_security_group.infrastructure_subnet_security_group.id
}

resource "azurerm_subnet_network_security_group_association" "services_subnet_security_group" {
  subnet_id                 = data.azurerm_subnet.services_subnet.id
  network_security_group_id = azurerm_network_security_group.services_subnet_security_group.id
}

# ============= DNS

locals {
  dns_subdomain = var.env_name
}

# resource "azurerm_dns_zone" "env_dns_zone" {
resource "azurerm_dns_zone" "env_dns_zone" {
  name                = "${var.dns_subdomain != "" ? var.dns_subdomain : local.dns_subdomain}.${var.dns_suffix}"
  resource_group_name = var.env_name
}
