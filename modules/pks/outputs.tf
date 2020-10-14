output "pks_lb_name" {
  value = "${azurerm_lb.pks-lb.name}"
}

output "pks_api_hostname" {
  value = "api.${azurerm_dns_a_record.pks-dns.zone_name}"
}

output "harbor_lb_name" {
  value = "${azurerm_lb.harbor-lb.name}"
}

output "harbor_hostname" {
  value = "harbor.${azurerm_dns_a_record.harbor-dns.zone_name}"
}
