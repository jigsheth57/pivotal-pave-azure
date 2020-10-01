variable "env_id" {}
variable "env_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "dns_zone_name" {}

variable "cf_buildpacks_storage_container_name" {}
variable "cf_droplets_storage_container_name" {}
variable "cf_packages_storage_container_name" {}
variable "cf_resources_storage_container_name" {}
variable "cf_storage_account_name" {}
variable "ssh_lb_private_ip" {}
variable "web_lb_private_ip" {}
variable "infra_subnet_id" {}

variable "network_name" {}
//variable "pas_subnet_cidr" {}
variable "services_subnet_cidr" {}

variable "bosh_deployed_vms_security_group_id" {}
