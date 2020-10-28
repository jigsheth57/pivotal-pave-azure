#!/bin/bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
set -o pipefail

PROGNAME=$(basename $0)
CWD=$PWD
TERRAFORM_OUTPUT_FILE=$CWD/terraform-output.json
TERRAFORM_INPUT_FILE=$CWD/terraform.tfvars
JUMPBOX_CERT=$CWD/jumpbox.pem
OS=$(uname)
export PATH=.:$PATH
export ARM_SKIP_PROVIDER_REGISTRATION=true
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
echo "Starting to pave Azure for prerequisite requirements ..."

if [ -f "$TERRAFORM_INPUT_FILE" ]; then
  if ! [ -x jq ]; then
    get_jq
  fi
  if ! [ -x terraform ]; then
    get_terrform
  fi
  $CWD/terraform init
  $CWD/terraform plan -out=tanzu-prereq.tfplan
  $CWD/terraform apply tanzu-prereq.tfplan
  $CWD/terraform output -json >$TERRAFORM_OUTPUT_FILE
  if ! [ -f "$JUMPBOX_CERT" ]; then
    $CWD/jq -r '.jumpbox_ssh_private_key.value' $TERRAFORM_OUTPUT_FILE >$JUMPBOX_CERT
  fi
  if [ -f "$JUMPBOX_CERT" ]; then
    chmod 400 $JUMPBOX_CERT
  fi
fi
trap : 0

echo >&2 '
************
*** DONE ***
************
'
