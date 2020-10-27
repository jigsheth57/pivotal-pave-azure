variable "env_name" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "location" {}
variable "azure_master_managed_identity" {
  description = "Managed Identity used for Kubernetes Master Nodes"
  type    = string
}
variable "azure_worker_managed_identity" {
  description = "Managed Identity used for Kubernetes Worker Nodes"
  type    = string
}
variable "cloud_name" {
  description = "The Azure cloud environment to use. Available values at https://www.terraform.io/docs/providers/azurerm/#environment"
  default     = "public"
}
variable "network_resource_group" {}
variable "pcf_virtual_network_address_space" {
  type    = list(string)
  default = ["10.0.4.0/23"]
}
variable "pcf_infrastructure_subnet" {
  type    = string
  default = "10.0.5.0/24"
}
variable "pcf_services_subnet" {
  type    = string
  default = "10.0.4.0/24"
}
