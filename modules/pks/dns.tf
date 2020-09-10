resource "azurerm_dns_a_record" "pks-dns" {
  name                = "api"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = "60"
  records             = [azurerm_public_ip.pks-lb-ip.ip_address]
}
resource "azurerm_dns_a_record" "harbor-dns" {
  name                = "harbor"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = "60"
  records             = [azurerm_public_ip.harbor-lb-ip.ip_address]
}
