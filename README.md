# Terraforming Azure

##Steps (assumes Linux environment)
1. Update values in terraform.tfvars
2. `cd terraforming-tanzu`
3. `./pave-azure.sh`
4. Update DNS entries
5. For Pivnet Token, Ops Manager credentials, Harbor password and LDAP entries (optional) update creds.yml
6. `azure-tanzu-automation/install-tanzu.sh` (see note below)
7. Review and finalize config in Ops Manager before applying changes.
8. Create PKS admin user `terraforming-tanzu/azure-tanzu-automation/create-pks-admin-user.sh`

#Note about install-tanzu.sh
The install will download files from PivNet and then upload them to Ops Manager.  If the machine you're running this on has sufficient bandwidth then continue with the above. Otherwise, you can log into the Ops Manager VM and execute the command there to greatly expedite the process.  To do so execute the following (assumes Linux environment).

5. `tar cvf tanzu-terraforming-azure.tar *`
6. `scp -o "StrictHostKeyChecking no" -i opsman.pem tanzu-terraforming-azure.tar ubuntu@opsman.<Environment Name>.<Your Domain>:~`
7. `ssh -o "StrictHostKeyChecking no" -i opsman.pem ubuntu@opsman.<Environment Name>.<Your Domain>`
8. `mkdir exelon`
9. `mv tanzu-terraforming-azure.tar exelon/`
10. `cd exelon`
11. `tar xvf tanzu-terraforming-azure.tar`
12. `cd azure-tanzu-automation`
13. `./install-tanzu.sh`

## Variables

- env_name: **(required)** An arbitrary unique name for namespacing resources
- subscription_id: **(required)** Azure account subscription id
- tenant_id: **(required)** Azure account tenant id
- client_id: **(required)** Azure automation account client id
- client_secret: **(required)** Azure automation account client secret
- ops_manager_image_uri: **(optional)** URL for an OpsMan image hosted on Azure (if not provided you get no Ops Manager)
- location: **(required)** Azure location to stand up environment in
- dns_suffix: **(required)** Domain to add environment subdomain to
