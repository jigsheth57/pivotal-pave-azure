variable "env_id" {}

variable "location" {}

variable "resource_group_name" {
  type = "string"
}
variable "dns_zone_name" {
  type = string
}
variable "network_name" {}

variable "resource_group_cidr" {}

variable "services_subnet_cidr" {}
variable "infrastructure_subnet_cidr" {}

//locals {
//  pks_cidr          = "${cidrsubnet(var.resource_group_cidr, 6, 3)}"
//  pks_services_cidr = "${cidrsubnet(var.resource_group_cidr, 6, 4)}"
//}

variable "bosh_deployed_vms_security_group_id" {}
