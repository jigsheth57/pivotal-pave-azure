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
		OM_FILE="https://github.com/pivotal-cf/om/releases/download/6.5.0/om-linux-6.5.0"
	elif [ $OS == "Darwin" ]; then
		OM_FILE="https://github.com/pivotal-cf/om/releases/download/6.5.0/om-darwin-6.5.0"
	fi
	WGET_CMD="wget -q $OM_FILE -O $CWD/om"
	if `$WGET_CMD`; then
		chmod 755 $CWD/om
	fi
}
trap 'abort' 0
echo "Create admin user for PKS on Azure"

if [ -f "$TERRAFORM_OUTPUT_FILE" ]; then
  if ! [ -x jq ]; then
    get_jq
  fi
  if ! [ -x om ]; then
    get_om
  fi
  TKGI_API_HOSTNAME=$($CWD/jq -r '.tkgi_api_hostname.value' $TERRAFORM_OUTPUT_FILE)
  UAA_ADMIN_SECRET=$($CWD/om --env $CWD/env-fix.yml credentials --product-name pivotal-container-service --credential-reference .properties.pks_uaa_management_admin_client --format json | $CWD/jq -r '.secret' )
  ADMIN_USER_SECRET=$(awk -F: '/^password/{gsub(/ /,"",$2); print $2}' $CWD/env-fix.yml)
  if ! [ -x "$(command -v uaac)" ]; then
    echo "ERROR: uaac is not installed!"
    echo "... run following commands, once you have uaac installed."
    echo "uaac target $TKGI_API_HOSTNAME:8443 --skip-ssl-validation" >remote-uaac-shell.sh
    echo "uaac token client get admin -s $UAA_ADMIN_SECRET" >>remote-uaac-shell.sh
    echo "uaac user add tkgiadmin --emails tkgiadmin@example.com -p $ADMIN_USER_SECRET" >>remote-uaac-shell.sh
    echo "uaac member add pks.clusters.admin tkgiadmin" >>remote-uaac-shell.sh
    OPS_MANAGER=$($CWD/jq -r '.ops_manager_dns.value' $TERRAFORM_OUTPUT_FILE)
    ssh-keygen -R $OPS_MANAGER
    ssh-keyscan -p 22 $OPS_MANAGER >opsman.keys
    chmod 755 remote-uaac-shell.sh
    scp -o UserKnownHostsFile=opsman.keys -i opsman.pem remote-uaac-shell.sh ubuntu@$OPS_MANAGER:
    ssh -o UserKnownHostsFile=opsman.keys -i opsman.pem ubuntu@$OPS_MANAGER '~/remote-uaac-shell.sh'
  else
    uaac target $TKGI_API_HOSTNAME:8443 --skip-ssl-validation
    uaac token client get admin -s $UAA_ADMIN_SECRET
    if [ `uaac user get tkgiadmin | grep -c 'id:'` -eq 0 ]; then
      uaac user add tkgiadmin --emails tkgiadmin@example.com -p $ADMIN_USER_SECRET
      uaac member add pks.clusters.admin tkgiadmin
    fi
  fi
fi
trap : 0

echo >&2 '
************
*** DONE ***
************
'
