# Terraforming Azure

## Preparation Steps
Before beginning you will need a Service Principal with the correct roles which will be used for the installation. Below is one way to accomplish this.

`az cloud set --name AzureCloud`
`az ad app create --display-name "Service Principal for BOSH" --password "PASSWORD" --homepage "http://BOSHAzureCPI" --identifier-uris "http://BOSHAzureCPI"`
`az ad sp create --id YOUR-APPLICATION-ID`
`az role assignment create --assignee "SERVICE-PRINCIPAL-NAME" --role "Contributor" --resource-group "RESOURCE-GROUP-NAME"`
`az role assignment list --assignee "SERVICE-PRINCIPAL-NAME" --resource-group "RESOURCE-GROUP-NAME"`
`az provider register --namespace Microsoft.Storage`
`az provider register --namespace Microsoft.Network`
`az provider register --namespace Microsoft.Compute`

## Prerequisite azure resources
This scripts expects following resources be provided prior to running script:
1. Resource Group (Tanzu will reside)
2. Managed Identities (Kubernetes Master & Worker Managed Identity)
3. Network Resource Group (vNet Resource Group)
4. Virtual Network
5. Infrastructure Subnet
6. Services Subnet

Note: you can use terraforming-tanzu/prereq/pave-azure.sh to automate above steps. Update the `terraforming-tanzu/prereq/terraform.tfvars` accordingly.

## Paving Azure Infrastructure Steps (assumes Linux environment and Prerequisite steps have been completed)
1. Update values in terraform.tfvars based on the prerequisite steps
2. `cd terraforming-tanzu`
3. `./pave-azure.sh`
4. Update DNS entries
5. For Pivnet Token, Ops Manager credentials, Harbor password and LDAP entries (optional) update `azure-tanzu-automation/creds.yml`
6. Make sure DNS entries are resolvable before continuing
7. Follow section Installing Tanzu Steps (see note below)

## Installing Tanzu Steps
1. `tar cvf azure-tanzu-automation.tar azure-tanzu-automation`
2. `export OPS_MANAGER=$(./jq -r '.ops_manager_dns.value' azure-tanzu-automation/terraform-output.json)`
2. `scp -o "StrictHostKeyChecking no" -i opsman.pem azure-tanzu-automation.tar ubuntu@$OPS_MANAGER:~`
3. `ssh -o "StrictHostKeyChecking no" -i opsman.pem ubuntu@$OPS_MANAGER`
4. `tar xvf azure-tanzu-automation.tar`
5. `cd azure-tanzu-automation`
6. `nohup ./install-tanzu.sh > ../install-tanzu-v1.out 2>&1 &`
7. `tail -f ../install-tanzu-v1.out`

## Variables

- env_name: **(required)** resource group name where tanzu will be installed
- subscription_id: **(required)** Azure account subscription id
- tenant_id: **(required)** Azure account tenant id
- client_id: **(required)** Azure automation account client id
- client_secret: **(required)** Azure automation account client secret
- ops_manager_image_uri: **(optional)** URL for an OpsMan image hosted on Azure (if not provided you get no Ops Manager)
- location: **(required)** Azure location to stand up environment in
- dns_suffix: **(required)** Domain to add subdomain
- dns_subdomain: **(required)** Subdomain
- azure_master_managed_identity: **(required)** user managed identity for k8s master nodes
- azure_worker_managed_identity: **(required)** user managed identity for k8s worker nodes
- network_resource_group: **(required)** resource group where virtual network resides
- virtual_network: **(required)** virtual network name to be used with tanzu
- infrastructure_subnet: **(required)** subnet where tanzu control plans will be installed
- services_subnet: **(required)** subnet where tas and k8s will reside.
