resource "azurerm_lb" "ssh-lb" {
  name                = "${var.env_name}-ssh-lb"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "ssh-lb-ip"
    subnet_id                     = var.infra_subnet_id
    private_ip_address_allocation = "static"
    private_ip_address            = var.ssh_lb_private_ip
  }
}

resource "azurerm_lb_backend_address_pool" "ssh-backend-pool" {
  name                = "${var.env_name}-ssh-backend-pool"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ssh-lb.id
}

resource "azurerm_lb_probe" "ssh-tcp-probe" {
  name                = "${var.env_name}-ssh-tcp-probe"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ssh-lb.id
  protocol            = "TCP"
  port                = 2222
}

resource "azurerm_lb_rule" "ssh-tcp-rule" {
  name                = "${var.env_name}-ssh-tcp-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ssh-lb.id

  frontend_ip_configuration_name = "ssh-lb-ip"
  protocol                       = "TCP"
  frontend_port                  = 2222
  backend_port                   = 2222
  idle_timeout_in_minutes        = 30

  backend_address_pool_id = azurerm_lb_backend_address_pool.ssh-backend-pool.id
  probe_id                = azurerm_lb_probe.ssh-tcp-probe.id
}

resource "azurerm_lb_rule" "ssh-ntp" {
  name                = "${var.env_name}-ssh-ntp-rule"
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.ssh-lb.id

  frontend_ip_configuration_name = "ssh-lb-ip"
  protocol                       = "UDP"
  frontend_port                  = "123"
  backend_port                   = "123"

  backend_address_pool_id = azurerm_lb_backend_address_pool.ssh-backend-pool.id
}
