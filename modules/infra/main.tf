variable "env_name" {
  default = ""
}

variable "location" {
  default = ""
}

variable "dns_subdomain" {
  default = ""
}

variable "dns_suffix" {
  default = ""
}

variable "pcf_virtual_network_address_space" {
  type    = list
  default = []
}

variable "pcf_infrastructure_subnet" {
  default = ""
}

# variable "virtual_network" {}

# resource "azurerm_resource_group" "pcf_resource_group" {
#   name     = "${var.env_name}"
#   location = "${var.location}"
# }

data "azurerm_resource_group" "pcf_resource_group" {
  name     = var.env_name
  # location = "${var.location}"
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

# ============= Networking

resource "azurerm_virtual_network" "pcf_virtual_network" {
  name                = "${var.env_name}-virtual-network"
  depends_on          = [data.azurerm_resource_group.pcf_resource_group]
  resource_group_name = data.azurerm_resource_group.pcf_resource_group.name
  address_space       = var.pcf_virtual_network_address_space
  location            = var.location
}

# Uncomment and change vars to use this if you want to use your own
# data "azurerm_virtual_network" "pcf_virtual_network" {
#   name                = "${var.virtual_network}"
#   resource_group_name = "${data.azurerm_resource_group.pcf_resource_group.name}"
# }

resource "azurerm_subnet" "infrastructure_subnet" {
  name                      = "${var.env_name}-infrastructure-subnet"
  depends_on                = [data.azurerm_resource_group.pcf_resource_group]
  resource_group_name       = data.azurerm_resource_group.pcf_resource_group.name
  virtual_network_name      = azurerm_virtual_network.pcf_virtual_network.name
  address_prefixes          = [var.pcf_infrastructure_subnet]
}

resource "azurerm_subnet_network_security_group_association" "infrastructure_subnet_security_group" {
  subnet_id                 = azurerm_subnet.infrastructure_subnet.id
  network_security_group_id = azurerm_network_security_group.infrastructure_subnet_security_group.id
}

# ============= DNS

locals {
  dns_subdomain = var.env_name
}

# resource "azurerm_dns_zone" "env_dns_zone" {
resource "azurerm_dns_zone" "env_dns_zone" {
  name                = "${var.dns_subdomain != "" ? var.dns_subdomain : local.dns_subdomain}.${var.dns_suffix}"
  resource_group_name = data.azurerm_resource_group.pcf_resource_group.name
}

output "dns_zone_name" {
  value = azurerm_dns_zone.env_dns_zone.name
}

output "dns_zone_name_servers" {
  value = azurerm_dns_zone.env_dns_zone.name_servers
}

output "resource_group_name" {
  value = data.azurerm_resource_group.pcf_resource_group.name
}

# output "network_name" {
#   value = "${data.azurerm_virtual_network.pcf_virtual_network.name}"
# }
output "network_name" {
  value = azurerm_virtual_network.pcf_virtual_network.name
}

output "infrastructure_subnet_id" {
  value = azurerm_subnet.infrastructure_subnet.id
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

output "security_group_id" {
  value = azurerm_network_security_group.infrastructure_subnet_security_group.id
}

output "security_group_name" {
  value = azurerm_network_security_group.infrastructure_subnet_security_group.name
}

output "bosh_deployed_vms_security_group_id" {
  value = azurerm_network_security_group.services_subnet_security_group.id
}

output "bosh_deployed_vms_security_group_name" {
  value = azurerm_network_security_group.services_subnet_security_group.name
}
