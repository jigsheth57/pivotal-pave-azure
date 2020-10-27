resource "azurerm_availability_set" "pks" {
  name                = "${var.env_name}-availability-set"
  location            = var.location
  resource_group_name = var.resource_group_name
}
