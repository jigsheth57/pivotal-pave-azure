#!/bin/bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
set -o pipefail

PROGNAME=$(basename $0)
CWD=$PWD
TERRAFORM_OUTPUT_FILE=$CWD/terraform-output.json
OS=$(uname)
export PATH=.:$PATH
function abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
		exit 1
}
function get_jq()
{
	if [ $OS == "Linux" ]; then
		JQ_FILE="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
	elif [ $OS == "Darwin" ]; then
		JQ_FILE="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64"
	fi
	WGET_CMD="wget -q $JQ_FILE -O $CWD/jq"
	if `$WGET_CMD`; then
		chmod 755 $CWD/jq
	fi
}
function get_om()
{
	if [ $OS == "Linux" ]; then
		OM_FILE="https://github.com/pivotal-cf/om/releases/download/6.1.1/om-linux-6.1.1"
	elif [ $OS == "Darwin" ]; then
		OM_FILE="https://github.com/pivotal-cf/om/releases/download/6.1.1/om-darwin-6.1.1"
	fi
	WGET_CMD="wget -q $OM_FILE -O $CWD/om"
	if `$WGET_CMD`; then
		chmod 755 $CWD/om
	fi
}
function get_pivnet()
{
	if [ $OS == "Linux" ]; then
		PIVNET_FILE="https://github.com/pivotal-cf/pivnet-cli/releases/download/v1.0.4/pivnet-linux-amd64-1.0.4"
	elif [ $OS == "Darwin" ]; then
		PIVNET_FILE="https://github.com/pivotal-cf/pivnet-cli/releases/download/v1.0.4/pivnet-darwin-amd64-1.0.4"
	fi
	WGET_CMD="wget -q $PIVNET_FILE -O $CWD/pivnet"
	if `$WGET_CMD`; then
		chmod 755 $CWD/pivnet
	fi
}
function get_clis()
{
  $CWD/pivnet login --api-token=$1
	if [ $OS == "Linux" ]; then
		$CWD/pivnet download-product-files --product-slug='pivotal-container-service' --release-version='1.8.1' --product-file-id=737302
    $CWD/pivnet download-product-files --product-slug='pivotal-container-service' --release-version='1.8.1' --product-file-id=737294
    mv pks-linux-amd64-* pks && chmod 755 pks
    mv kubectl-linux-amd64-* kubectl && chmod 755 kubectl
	elif [ $OS == "Darwin" ]; then
		$CWD/pivnet download-product-files --product-slug='pivotal-container-service' --release-version='1.8.1' --product-file-id=737301
    $CWD/pivnet download-product-files --product-slug='pivotal-container-service' --release-version='1.8.1' --product-file-id=737293
    mv pks-darwin-amd64-* pks && chmod 755 pks
    mv kubectl-darwin-amd64-* kubectl && chmod 755 kubectl
	fi
}

trap 'abort' 0
echo "Staring installation of Tanzu on Azure"

if [ -f "$TERRAFORM_OUTPUT_FILE" ]; then
  if ! [ -x jq ]; then
    get_jq
  fi
  if ! [ -x om ]; then
    get_om
  fi
  if ! [ -x pivnet ]; then
    get_pivnet
  fi
  OPS_MANAGER=$($CWD/jq -r '.ops_manager_dns.value' $TERRAFORM_OUTPUT_FILE)
	$CWD/jq -r '"om-target: \(.ops_manager_dns.value)", "azure-bosh-storage-account-name: \(.bosh_root_storage_account.value)", "azure-client-id: \(.client_id.value)", "azure-client-secret: \(.client_secret.value)", "azure-subscription-id: \(.subscription_id.value)", "azure-tenant-id: \(.tenant_id.value)", "azure-ssh-public-key.public_key: \(.ops_manager_ssh_public_key.value)", "pks-api-hostname: \(.pks_api_hostname.value)", "pks-lb-name: \(.pks_lb_name.value)", "pcf-resource-group-name: \(.pcf_resource_group_name.value)", "location: \(.location.value)", "master-managed-identity: \(.master_managed_identity.value)", "worker-managed-identity: \(.worker_managed_identity.value)", "harbor-hostname: \(.harbor_hostname.value)", "harbor-lb-name: \(.harbor_lb_name.value)", "apps-domain: \(.apps_domain.value)", "sys-domain: \(.sys_domain.value)", "cf-storage-account-name: \(.cf_storage_account_name.value)", "cf-storage-account-access-key: \(.cf_storage_account_access_key.value)", "cf-droplets-storage-container: \(.cf_droplets_storage_container.value)", "cf-packages-storage-container: \(.cf_packages_storage_container.value)", "cf-resources-storage-container: \(.cf_resources_storage_container.value)", "cf-buildpacks-storage-container: \(.cf_buildpacks_storage_container.value)", "infrastructure-subnet-name: \(.infrastructure_subnet_name.value)", "services-subnet-name: \(.services_subnet_name.value)", "web-lb-name: \(.web_lb_name.value)", "diego-ssh-lb-name: \(.diego_ssh_lb_name.value)"' $TERRAFORM_OUTPUT_FILE >$CWD/terraform-creds.yml
	echo "azure-ssh-public-key.private_key: $($CWD/jq '.ops_manager_ssh_private_key.value' $TERRAFORM_OUTPUT_FILE)" >>$CWD/terraform-creds.yml
  ADMIN_USER_SECRET=$(awk -F: '/^om-password/{gsub(/ /,"",$2); print $2}' $CWD/creds.yml)
  echo "registry-admin-password: $ADMIN_USER_SECRET" >>$CWD/terraform-creds.yml
	$CWD/om interpolate -c $CWD/env.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/env-fix.yml
	$CWD/om interpolate -c $CWD/auth.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/auth-fix.yml
	$CWD/om interpolate -c $CWD/director.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/director-fix.yml
  until nc -z $OPS_MANAGER 443; do echo waiting for $OPS_MANAGER:443; sleep 2; done;
  sleep 30;
	$CWD/om --env $CWD/env-fix.yml configure-authentication --config $CWD/auth-fix.yml
	$CWD/om --env $CWD/env-fix.yml configure-director --config $CWD/director-fix.yml
	$CWD/om --env $CWD/env-fix.yml apply-changes --skip-deploy-products

  $CWD/om --env $CWD/env-fix.yml generate-certificate -d "$($CWD/jq -r '.pks_api_hostname.value' $TERRAFORM_OUTPUT_FILE)" | $CWD/jq '.certificate,.key' > pks-api.cert
  echo "pksapi-cert.certificate: "$(head -n 1 pks-api.cert) >>$CWD/terraform-creds.yml
  echo "pksapi-cert.private_key: "$(tail -n 1 pks-api.cert) >>$CWD/terraform-creds.yml

  $CWD/om --env $CWD/env-fix.yml generate-certificate -d "$($CWD/jq -r '.harbor_hostname.value' $TERRAFORM_OUTPUT_FILE)" | $CWD/jq '.certificate,.key' > harbor.cert
  echo "harbor-cert.certificate: "$(head -n 1 harbor.cert) >>$CWD/terraform-creds.yml
  echo "harbor-cert.private_key: "$(tail -n 1 harbor.cert) >>$CWD/terraform-creds.yml

  $CWD/om --env $CWD/env-fix.yml generate-certificate -d "*.$($CWD/jq -r '.sys_domain.value' $TERRAFORM_OUTPUT_FILE), *.$($CWD/jq -r '.apps_domain.value' $TERRAFORM_OUTPUT_FILE), *.uaa.$($CWD/jq -r '.sys_domain.value' $TERRAFORM_OUTPUT_FILE), *.login.$($CWD/jq -r '.sys_domain.value' $TERRAFORM_OUTPUT_FILE)" | $CWD/jq '.certificate,.key' > srt.cert
  echo "srt-cert.certificate: "$(head -n 1 srt.cert) >>$CWD/terraform-creds.yml
  echo "srt-cert.private_key: "$(tail -n 1 srt.cert) >>$CWD/terraform-creds.yml

  $CWD/om interpolate -c $CWD/srt.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/srt-fix.yml
  $CWD/om interpolate -c $CWD/pks.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/pks-fix.yml
  $CWD/om interpolate -c $CWD/harbor-container-registry.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/harbor-container-registry-fix.yml

  # Download & upload tiles to Ops Manager
  PIVNET_DOWNLOADED_FILE=$CWD/downloaded-files
	if [ ! -d "$PIVNET_DOWNLOADED_FILE" ]; then
		mkdir $PIVNET_DOWNLOADED_FILE
	fi

  $CWD/om interpolate -c $CWD/download-pks.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/download-pks-fix.yml
	$CWD/om download-product --config $CWD/download-pks-fix.yml --output-directory $PIVNET_DOWNLOADED_FILE
  PRODUCT_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path /product_path)
	$CWD/om --env $CWD/env-fix.yml upload-product --product $PRODUCT_PATH
  STEMCELL_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path '/stemcell_path?')
	$CWD/om --env $CWD/env-fix.yml upload-stemcell --floating true --stemcell $STEMCELL_PATH
  $CWD/om --env $CWD/env-fix.yml stage-product --product-name $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-name) --product-version $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-version)
  $CWD/om --env $CWD/env-fix.yml configure-product --config $CWD/pks-fix.yml

  $CWD/om interpolate -c $CWD/download-harbor.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/download-harbor-fix.yml
  $CWD/om download-product --config $CWD/download-harbor-fix.yml --output-directory $PIVNET_DOWNLOADED_FILE
  PRODUCT_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path /product_path)
	$CWD/om --env $CWD/env-fix.yml upload-product --product $PRODUCT_PATH
  STEMCELL_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path '/stemcell_path?')
  $CWD/om --env $CWD/env-fix.yml upload-stemcell --floating true --stemcell $STEMCELL_PATH
  $CWD/om --env $CWD/env-fix.yml stage-product --product-name $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-name) --product-version $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-version)
  $CWD/om --env $CWD/env-fix.yml configure-product --config $CWD/harbor-container-registry-fix.yml

  $CWD/om interpolate -c $CWD/download-srt.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/download-srt-fix.yml
	$CWD/om download-product --config $CWD/download-srt-fix.yml --output-directory $PIVNET_DOWNLOADED_FILE
  PRODUCT_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path /product_path)
	$CWD/om --env $CWD/env-fix.yml upload-product --product $PRODUCT_PATH
  STEMCELL_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path '/stemcell_path?')
  $CWD/om --env $CWD/env-fix.yml upload-stemcell --floating true --stemcell $STEMCELL_PATH
  $CWD/om --env $CWD/env-fix.yml stage-product --product-name $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-name) --product-version $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-version)
  $CWD/om --env $CWD/env-fix.yml configure-product --config $CWD/srt-fix.yml

  $CWD/om interpolate -c $CWD/download-metricstore.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/download-metricstore-fix.yml
	$CWD/om download-product --config $CWD/download-metricstore-fix.yml --output-directory $PIVNET_DOWNLOADED_FILE
  PRODUCT_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path /product_path)
	$CWD/om --env $CWD/env-fix.yml upload-product --product $PRODUCT_PATH
  STEMCELL_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path '/stemcell_path?')
  $CWD/om --env $CWD/env-fix.yml upload-stemcell --floating true --stemcell $STEMCELL_PATH
  $CWD/om --env $CWD/env-fix.yml stage-product --product-name $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-name) --product-version $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-version)
  $CWD/om --env $CWD/env-fix.yml configure-product --config $CWD/metric-store.yml

  $CWD/om interpolate -c $CWD/download-apm.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/download-apm-fix.yml
	$CWD/om download-product --config $CWD/download-apm-fix.yml --output-directory $PIVNET_DOWNLOADED_FILE
  PRODUCT_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path /product_path)
	$CWD/om --env $CWD/env-fix.yml upload-product --product $PRODUCT_PATH
  STEMCELL_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path '/stemcell_path?')
  $CWD/om --env $CWD/env-fix.yml upload-stemcell --floating true --stemcell $STEMCELL_PATH
  $CWD/om --env $CWD/env-fix.yml stage-product --product-name $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-name) --product-version $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-version)
  $CWD/om --env $CWD/env-fix.yml configure-product --config $CWD/app-metrics.yml

  $CWD/om interpolate -c $CWD/download-healthwatch.yml -l $CWD/creds.yml -l $CWD/terraform-creds.yml -s >$CWD/download-healthwatch-fix.yml
	$CWD/om download-product --config $CWD/download-healthwatch-fix.yml --output-directory $PIVNET_DOWNLOADED_FILE
  PRODUCT_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path /product_path)
	$CWD/om --env $CWD/env-fix.yml upload-product --product $PRODUCT_PATH
  STEMCELL_PATH=$($CWD/om interpolate --config $PIVNET_DOWNLOADED_FILE/download-file.json --path '/stemcell_path?')
  $CWD/om --env $CWD/env-fix.yml upload-stemcell --floating true --stemcell $STEMCELL_PATH
  $CWD/om --env $CWD/env-fix.yml stage-product --product-name $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-name) --product-version $($CWD/om product-metadata --product-path $PRODUCT_PATH --product-version)
  $CWD/om --env $CWD/env-fix.yml configure-product --config $CWD/p-healthwatch.yml


  $CWD/om --env $CWD/env-fix.yml apply-changes

  if ! [[ -x kubectl && -x pks ]]; then
    PIVNET_TOKEN=$(awk -F: '/^pivnet-token/{gsub(/ /,"",$2); print $2}' $CWD/creds.yml)
    get_clis $PIVNET_TOKEN
  fi
  ./create-pks-admin-user.sh

fi
trap : 0

echo >&2 '
************
*** DONE ***
************
'
