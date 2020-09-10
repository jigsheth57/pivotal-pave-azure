resource "azurerm_dns_a_record" "apps" {
  name                = "*.apps"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = "60"
  records             = ["${azurerm_public_ip.web-lb-ip.ip_address}"]
}

resource "azurerm_dns_a_record" "sys" {
  name                = "*.sys"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = "60"
  records             = ["${azurerm_public_ip.web-lb-ip.ip_address}"]
}

resource "azurerm_dns_a_record" "ssh" {
  name                = "ssh.sys"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = "60"
  records             = ["${azurerm_public_ip.ssh-lb-ip.ip_address}"]
}
