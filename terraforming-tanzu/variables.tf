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
variable "dns_suffix" {}
variable "dns_subdomain" {
  type        = string
  description = "The base subdomain used for PCF. For example, if your dns_subdomain is `cf`, and your dns_suffix is `pivotal.io`, your PCF domain would be `cf.pivotal.io`"
  default     = ""
}
variable "cloud_name" {
  description = "The Azure cloud environment to use. Available values at https://www.terraform.io/docs/providers/azurerm/#environment"
  default     = "public"
}
variable "network_resource_group" {}
variable "virtual_network" {}
variable "infrastructure_subnet" {}
variable "services_subnet" {}

variable "infrastructure_subnet_reserved_ip_range" {
  description = "Reserved IPs in infrastructure subnet"
  type    = string
  default = "10.0.5.0-10.0.5.25"
}
variable "services_subnet_reserved_ip_range" {
  description = "Reserved IPs in services subnet"
  type    = string
  default = "10.0.4.0-10.0.4.10"
}

variable "ops_manager_image_uri" {
  type        = string
  description = "Ops Manager image on Azure. Ops Manager VM will be skipped if this is empty"
}

variable "ops_manager_private_ip" {
  type        = string
  description = "IP for the Ops Manager instance in infrastructure subnet"
  default     = "10.0.5.4"
}

variable "harbor_lb_private_ip" {
  type        = string
  description = "IP for the internal Azure LB instance from infrastructure subnet"
  default     = "10.0.5.5"
}

variable "tkgi_lb_private_ip" {
  type        = string
  description = "IP for the internal Azure LB instance from infrastructure subnet"
  default     = "10.0.5.9"
}

variable "ssh_lb_private_ip" {
  type        = string
  description = "IP for the internal Azure LB instance from infrastructure subnet"
  default     = "10.0.5.13"
}

variable "web_lb_private_ip" {
  type        = string
  description = "IP for the internal Azure LB instance from infrastructure subnet"
  default     = "10.0.5.17"
}

variable "ops_manager_vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "cf_storage_account_name" {
  type        = string
  description = "storage account name for cf"
  default     = "cf"
}

variable "cf_buildpacks_storage_container_name" {
  type        = string
  description = "container name for cf buildpacks"
  default     = "buildpacks"
}

variable "cf_packages_storage_container_name" {
  type        = string
  description = "container name for cf packages"
  default     = "packages"
}

variable "cf_droplets_storage_container_name" {
  type        = string
  description = "container name for cf droplets"
  default     = "droplets"
}

variable "cf_resources_storage_container_name" {
  type        = string
  description = "container name for cf resources"
  default     = "resources"
}

variable "ssl_cert" {
  type        = string
  description = "the contents of an SSL certificate which should be passed to the gorouter, optional if `ssl_ca_cert` is provided"
  default     = ""
}

variable "ssl_private_key" {
  type        = string
  description = "the contents of an SSL private key which should be passed to the gorouter, optional if `ssl_ca_cert` is provided"
  default     = ""
}

variable "ssl_ca_cert" {
  type        = string
  description = "the contents of a CA public key to be used to sign a generated certificate for gorouter, optional if `ssl_cert` is provided"
  default     = ""
}

variable "ssl_ca_private_key" {
  type        = string
  description = "the contents of a CA private key to be used to sign a generated certificate for gorouter, optional if `ssl_cert` is provided"
  default     = ""
}
