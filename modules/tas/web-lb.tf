resource "azurerm_lb" "web-lb" {
  name                = "${var.env_name}-web-lb"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "web-lb-ip"
    subnet_id                     = var.infra_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.web_lb_private_ip
  }
}

resource "azurerm_lb_backend_address_pool" "web-backend-pool" {
  name                = "${var.env_name}-web-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.web-lb.id
}

resource "azurerm_lb_probe" "web-https-probe" {
  name                = "${var.env_name}-web-https-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.web-lb.id
  protocol            = "TCP"
  port                = 443
}

resource "azurerm_lb_rule" "web-https-rule" {
  name                = "${var.env_name}-web-https-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.web-lb.id

  frontend_ip_configuration_name = "web-lb-ip"
  protocol                       = "TCP"
  frontend_port                  = 443
  backend_port                   = 443
  idle_timeout_in_minutes        = 30

  backend_address_pool_id = azurerm_lb_backend_address_pool.web-backend-pool.id
  probe_id                = azurerm_lb_probe.web-https-probe.id
}

resource "azurerm_lb_probe" "web-http-probe" {
  name                = "${var.env_name}-web-http-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.web-lb.id
  protocol            = "TCP"
  port                = 80
}

resource "azurerm_lb_rule" "web-http-rule" {
  name                = "${var.env_name}-web-http-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.web-lb.id

  frontend_ip_configuration_name = "web-lb-ip"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 80
  idle_timeout_in_minutes        = 30

  backend_address_pool_id = azurerm_lb_backend_address_pool.web-backend-pool.id
  probe_id                = azurerm_lb_probe.web-http-probe.id
}

resource "azurerm_lb_rule" "web-ntp" {
  name                = "${var.env_name}-web-ntp-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.web-lb.id

  frontend_ip_configuration_name = "web-lb-ip"
  protocol                       = "UDP"
  frontend_port                  = "123"
  backend_port                   = "123"

  backend_address_pool_id = azurerm_lb_backend_address_pool.web-backend-pool.id
}
