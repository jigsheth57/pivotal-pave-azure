resource "azurerm_availability_set" "tkgi_availability_set" {
  name                = "${var.env_name}-tkgi-availability-set"
  location            = var.location
  resource_group_name = var.resource_group_name
}
