resource "azurerm_dns_a_record" "apps" {
  name                = "*.apps"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = "60"
  records             = ["${var.web_lb_private_ip}"]
}

resource "azurerm_dns_a_record" "sys" {
  name                = "*.sys"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = "60"
  records             = ["${var.web_lb_private_ip}"]
}

resource "azurerm_dns_a_record" "ssh" {
  name                = "ssh.sys"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = "60"
  records             = ["${var.ssh_lb_private_ip}"]
}
