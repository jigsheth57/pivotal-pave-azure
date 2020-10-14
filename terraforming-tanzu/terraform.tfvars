# https://docs.pivotal.io/platform/ops-manager/2-9/azure/prepare-azure-terraform.html
# az cloud set --name AzureCloud
# az ad app create --display-name "Service Principal for BOSH" --password "PASSWORD" --homepage "http://BOSHAzureCPI" --identifier-uris "http://BOSHAzureCPI"
# az ad sp create --id YOUR-APPLICATION-ID
# az role assignment create --assignee "SERVICE-PRINCIPAL-NAME" --role "Contributor" --resource-group "RESOURCE-GROUP-NAME"
# az role assignment list --assignee "SERVICE-PRINCIPAL-NAME" --resource-group "RESOURCE-GROUP-NAME"
# az provider register --namespace Microsoft.Storage
# az provider register --namespace Microsoft.Network
# az provider register --namespace Microsoft.Compute

subscription_id       = "XXXX"
tenant_id             = "XXXX"
client_id             = "XXXX"
client_secret         = "XXXX"

# Resource Group name is the env_name
env_name              = "exelondemo"

location              = "CentralUS"
ops_manager_image_uri = "https://opsmanagereastus.blob.core.windows.net/images/ops-manager-2.9.11-build.186.vhd"
dns_suffix            = "azure.tanzuapps.org"
dns_subdomain         = "exelondemo"
azure_master_managed_identity = "pks-master"
azure_worker_managed_identity = "pks-worker"
