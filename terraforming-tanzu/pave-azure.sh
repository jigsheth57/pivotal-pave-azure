#!/bin/bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
set -o pipefail

PROGNAME=$(basename $0)
CWD=$PWD
TERRAFORM_OUTPUT_FILE=$CWD/azure-tanzu-automation/terraform-output.json
OPSMAN_CERT=$CWD/opsman.pem
TERRAFORM_INPUT_FILE=$CWD/terraform.tfvars
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
function get_terrform()
{
	if [ $OS == "Linux" ]; then
		TERRAFORM_FILE="https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip"
	elif [ $OS == "Darwin" ]; then
		TERRAFORM_FILE="https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_darwin_amd64.zip"
	fi
	WGET_CMD="wget -q $TERRAFORM_FILE -O $CWD/terraform.zip"
	if `$WGET_CMD`; then
		unzip -o $CWD/terraform.zip && chmod 755 $CWD/terraform
	fi
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
trap 'abort' 0
echo "Starting to pave Azure for TKGI installation"

if [ -f "$TERRAFORM_INPUT_FILE" ]; then
  get_jq
	get_terrform
  $CWD/terraform init
  $CWD/terraform plan -out=tanzu.tfplan
  $CWD/terraform apply tanzu.tfplan
  $CWD/terraform output -json >$TERRAFORM_OUTPUT_FILE
  NS_RECORDS=$($CWD/jq -r '.env_dns_zone_name_servers.value[]' $TERRAFORM_OUTPUT_FILE)
  DOMAIN_ZONE=$($CWD/jq -r '.pks_api_hostname.value' $TERRAFORM_OUTPUT_FILE | cut -d'.' -f2-)
  echo -e "Make sure following NS entries have been added to your external facing DNS ($DOMAIN_ZONE) before proceeding:\n$NS_RECORDS"
  # read -p "Will continue in 2 minutes, please update your public DNS server ($DOMAIN_ZONE) with above NS records...." -t 120
  # echo "Will continue in 2 minutes ...."
  # sleep 120
  $CWD/jq -r '.ops_manager_ssh_private_key.value' $TERRAFORM_OUTPUT_FILE >$OPSMAN_CERT
  if [ -f "$OPSMAN_CERT" ]; then
    chmod 400 $OPSMAN_CERT
  fi
  echo "Once DNS is configured, run following command: 'cd azure-tanzu-automation && ./install-tanzu.sh'"
  # cd azure-tanzu-automation
  # ./install-tanzu.sh
fi
trap : 0

echo >&2 '
************
*** DONE ***
************
'
