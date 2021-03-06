# https://docs.pivotal.io/platform/ops-manager/2-9/azure/prepare-azure-terraform.html
# az cloud set --name AzureCloud
# az ad app create --display-name "Service Principal for BOSH" --password "PASSWORD" --homepage "http://BOSHAzureCPI" --identifier-uris "http://BOSHAzureCPI"
# az ad sp create --id YOUR-APPLICATION-ID
# az role assignment create --assignee "SERVICE-PRINCIPAL-NAME" --role "Owner" --resource-group "RESOURCE-GROUP-NAME"
# az role assignment list --assignee "SERVICE-PRINCIPAL-NAME" --resource-group "RESOURCE-GROUP-NAME"
# az provider register --namespace Microsoft.Storage
# az provider register --namespace Microsoft.Network
# az provider register --namespace Microsoft.Compute

subscription_id       = "32e53c10-5a1c-49d8-871b-ea707baXXXXX"
tenant_id             = "29248f74-371f-4db2-9a50-c62a687XXXXX"
client_id             = "0624d853-16b2-4641-a567-d511106XXXXX"
client_secret         = "5xszfq6mVXXXX"

# Resource Group name is the env_name
env_name              = "exelondemo"

location              = "CentralUS"
ops_manager_image_uri = "https://opsmanagereastus.blob.core.windows.net/images/ops-manager-2.9.11-build.186.vhd"
dns_suffix            = "azure.tanzuapps.org"
vm_admin_username     = "ubuntu"
