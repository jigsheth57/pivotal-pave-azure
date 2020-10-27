resource "azurerm_lb" "harbor-lb" {
  name                = "${var.env_name}-harbor-lb"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "harbor-lb-ip"
    subnet_id                     = var.infra_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.harbor_lb_private_ip
  }
}

resource "azurerm_lb_backend_address_pool" "harbor-backend-pool" {
  name                = "${var.env_name}-harbor-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.harbor-lb.id
}

resource "azurerm_lb_probe" "harbor-https-probe" {
  name                = "${var.env_name}-harbor-https-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.harbor-lb.id
  protocol            = "TCP"
  port                = 443
}

resource "azurerm_lb_rule" "harbor-https-rule" {
  name                = "${var.env_name}-harbor-https-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.harbor-lb.id

  frontend_ip_configuration_name = "harbor-lb-ip"
  protocol                       = "TCP"
  frontend_port                  = 443
  backend_port                   = 443
  idle_timeout_in_minutes        = 30

  backend_address_pool_id = azurerm_lb_backend_address_pool.harbor-backend-pool.id
  probe_id                = azurerm_lb_probe.harbor-https-probe.id
}

resource "azurerm_lb_probe" "harbor-http-probe" {
  name                = "${var.env_name}-harbor-http-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.harbor-lb.id
  protocol            = "TCP"
  port                = 80
}

resource "azurerm_lb_rule" "harbor-http-rule" {
  name                = "${var.env_name}-harbor-http-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.harbor-lb.id

  frontend_ip_configuration_name = "harbor-lb-ip"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 80
  idle_timeout_in_minutes        = 30

  backend_address_pool_id = azurerm_lb_backend_address_pool.harbor-backend-pool.id
  probe_id                = azurerm_lb_probe.harbor-http-probe.id
}

resource "azurerm_lb_rule" "harbor-ntp" {
  name                = "${var.env_name}-harbor-ntp-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.harbor-lb.id

  frontend_ip_configuration_name = "harbor-lb-ip"
  protocol                       = "UDP"
  frontend_port                  = "123"
  backend_port                   = "123"

  backend_address_pool_id = azurerm_lb_backend_address_pool.harbor-backend-pool.id
}
