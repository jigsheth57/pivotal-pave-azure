resource "azurerm_lb" "pks-lb" {
  name                = "${var.env_name}-pks-lb"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "pks-lb-ip"
    subnet_id                     = var.infra_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.pks_lb_private_ip
  }
}

resource "azurerm_lb_backend_address_pool" "pks-lb-backend-pool" {
  name                = "${var.env_name}-pks-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.pks-lb.id
}

resource "azurerm_lb_probe" "pks-lb-uaa-health-probe" {
  name                = "${var.env_name}-pks-lb-uaa-health-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.pks-lb.id
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
  port                = 8443
}

resource "azurerm_lb_rule" "pks-lb-uaa-rule" {
  name                           = "${var.env_name}-pks-lb-uaa-rule"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.pks-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 8443
  backend_port                   = 8443
  frontend_ip_configuration_name = "pks-lb-ip"
  probe_id                       = azurerm_lb_probe.pks-lb-uaa-health-probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pks-lb-backend-pool.id
}

resource "azurerm_lb_probe" "pks-lb-api-health-probe" {
  name                = "${var.env_name}-pks-lb-api-health-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.pks-lb.id
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
  port                = 9021
}

resource "azurerm_lb_rule" "pks-lb-api-rule" {
  name                           = "${var.env_name}-pks-lb-api-rule"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.pks-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 9021
  backend_port                   = 9021
  frontend_ip_configuration_name = "pks-lb-ip"
  probe_id                       = azurerm_lb_probe.pks-lb-api-health-probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pks-lb-backend-pool.id
}
