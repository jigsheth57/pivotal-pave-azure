variable "env_id" {}

variable "location" {}

variable "resource_group_name" {
  type = string
}
variable "dns_zone_name" {
  type = string
}
variable "network_name" {}

variable "resource_group_cidr" {}

variable "services_subnet_cidr" {}
variable "infrastructure_subnet_cidr" {}

variable "infra_subnet_id" {}
variable "harbor_lb_private_ip" {}
variable "pks_lb_private_ip" {}

variable "bosh_deployed_vms_security_group_id" {}
