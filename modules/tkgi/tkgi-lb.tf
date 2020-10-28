resource "azurerm_lb" "tkgi-lb" {
  name                = "${var.env_name}-tkgi-lb"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "tkgi-lb-ip"
    subnet_id                     = var.infra_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.tkgi_lb_private_ip
  }
}

resource "azurerm_lb_backend_address_pool" "tkgi-lb-backend-pool" {
  name                = "${var.env_name}-tkgi-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.tkgi-lb.id
}

resource "azurerm_lb_probe" "tkgi-lb-uaa-health-probe" {
  name                = "${var.env_name}-tkgi-lb-uaa-health-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.tkgi-lb.id
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
  port                = 8443
}

resource "azurerm_lb_rule" "tkgi-lb-uaa-rule" {
  name                           = "${var.env_name}-tkgi-lb-uaa-rule"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.tkgi-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 8443
  backend_port                   = 8443
  frontend_ip_configuration_name = "tkgi-lb-ip"
  probe_id                       = azurerm_lb_probe.tkgi-lb-uaa-health-probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.tkgi-lb-backend-pool.id
}

resource "azurerm_lb_probe" "tkgi-lb-api-health-probe" {
  name                = "${var.env_name}-tkgi-lb-api-health-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.tkgi-lb.id
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
  port                = 9021
}

resource "azurerm_lb_rule" "tkgi-lb-api-rule" {
  name                           = "${var.env_name}-tkgi-lb-api-rule"
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.tkgi-lb.id
  protocol                       = "Tcp"
  frontend_port                  = 9021
  backend_port                   = 9021
  frontend_ip_configuration_name = "tkgi-lb-ip"
  probe_id                       = azurerm_lb_probe.tkgi-lb-api-health-probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.tkgi-lb-backend-pool.id
}
