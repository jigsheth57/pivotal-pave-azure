# https://docs.pivotal.io/platform/ops-manager/2-9/azure/prepare-azure-terraform.html
# az cloud set --name AzureCloud
# az ad app create --display-name "Service Principal for BOSH" --password "PASSWORD" --homepage "http://BOSHAzureCPI" --identifier-uris "http://BOSHAzureCPI"
# az ad sp create --id YOUR-APPLICATION-ID
# az role assignment create --assignee "SERVICE-PRINCIPAL-NAME" --role "Contributor" --resource-group "RESOURCE-GROUP-NAME"
# az role assignment list --assignee "SERVICE-PRINCIPAL-NAME" --resource-group "RESOURCE-GROUP-NAME"
# az provider register --namespace Microsoft.Storage
# az provider register --namespace Microsoft.Network
# az provider register --namespace Microsoft.Compute

subscription_id       = "XXXXX"
tenant_id             = "XXXXX"
client_id             = "XXXXX"
client_secret         = "XXXXX"

# Resource Group name is the env_name
env_name              = "exelon-demo"

location              = "CentralUS"
ops_manager_image_uri = "https://opsmanagereastus.blob.core.windows.net/images/ops-manager-2.9.12-build.198.vhd"
dns_suffix            = "azure.tanzuapps.org"
dns_subdomain         = "exelondemo"
azure_master_managed_identity = "tkgi-master"
azure_worker_managed_identity = "tkgi-worker"
network_resource_group = "exelon-demo-net"
virtual_network = "exelon-demo-net-virtual-network"
infrastructure_subnet = "exelon-demo-net-infrastructure-subnet"
services_subnet = "exelon-demo-net-services-subnet"
