output "tkgi_lb_name" {
  value = azurerm_lb.tkgi-lb.name
}

output "tkgi_api_hostname" {
#  value = "api.${azurerm_dns_a_record.tkgi-dns.zone_name}"
  value = "api.${var.dns_subdomain}.${var.dns_suffix}"
}

output "harbor_lb_name" {
  value = azurerm_lb.harbor-lb.name
}

output "harbor_hostname" {
#  value = "harbor.${azurerm_dns_a_record.harbor-dns.zone_name}"
  value = "harbor.${var.dns_subdomain}.${var.dns_suffix}"
}

output "tkgi_availability_set" {
  value = azurerm_availability_set.tkgi_availability_set.name
}
