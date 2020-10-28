resource "azurerm_dns_a_record" "tkgi-dns" {
  name                = "api"
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = "60"
  records             = [var.tkgi_lb_private_ip]
}
resource "azurerm_dns_a_record" "harbor-dns" {
  name                = "harbor"
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = "60"
  records             = [var.harbor_lb_private_ip]
}
