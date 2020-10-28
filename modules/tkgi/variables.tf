variable "env_name" {}

variable "location" {}

variable "resource_group_name" {
  type = string
}
variable "dns_zone_name" {
  type = string
}

variable "infra_subnet_id" {}

variable "harbor_lb_private_ip" {}

variable "tkgi_lb_private_ip" {}
