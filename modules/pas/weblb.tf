resource "azurerm_public_ip" "web-lb-ip" {
  name                    = "web-lb-ip"
  location                = "${var.location}"
  resource_group_name     = "${var.resource_group_name}"
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 30
}

resource "azurerm_lb" "web-lb" {
  name                = "${var.env_id}-web-lb"
  location            = "${var.location}"
  sku                 = "Standard"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                 = "${azurerm_public_ip.web-lb-ip.name}"
    subnet_id                     = "${var.infra_subnet_id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.web_lb_private_ip}"
#    public_ip_address_id = "${azurerm_public_ip.web-lb-ip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "web-backend-pool" {
  name                = "${var.env_id}-web-backend-pool"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"
}

resource "azurerm_lb_probe" "web-https-probe" {
  name                = "${var.env_id}-web-https-probe"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"
  protocol            = "TCP"
  port                = 443
}

resource "azurerm_lb_rule" "web-https-rule" {
  name                = "${var.env_id}-web-https-rule"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"

  frontend_ip_configuration_name = "${azurerm_public_ip.web-lb-ip.name}"
  protocol                       = "TCP"
  frontend_port                  = 443
  backend_port                   = 443
  idle_timeout_in_minutes        = 30

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.web-backend-pool.id}"
  probe_id                = "${azurerm_lb_probe.web-https-probe.id}"
}

resource "azurerm_lb_probe" "web-http-probe" {
  name                = "${var.env_id}-web-http-probe"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"
  protocol            = "TCP"
  port                = 80
}

resource "azurerm_lb_rule" "web-http-rule" {
  name                = "${var.env_id}-web-http-rule"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"

  frontend_ip_configuration_name = "${azurerm_public_ip.web-lb-ip.name}"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 80
  idle_timeout_in_minutes        = 30

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.web-backend-pool.id}"
  probe_id                = "${azurerm_lb_probe.web-http-probe.id}"
}

resource "azurerm_lb_rule" "web-ntp" {
  name                = "${var.env_id}-web-ntp-rule"
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.web-lb.id}"

  frontend_ip_configuration_name = "${azurerm_public_ip.web-lb-ip.name}"
  protocol                       = "UDP"
  frontend_port                  = "123"
  backend_port                   = "123"

  backend_address_pool_id = "${azurerm_lb_backend_address_pool.web-backend-pool.id}"
}
