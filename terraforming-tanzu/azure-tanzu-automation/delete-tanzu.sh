#!/bin/bash

set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables
set -o pipefail

CWD=$PWD
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
echo "Delete installtion of PKS on Azure"

if ! [ -x om ]; then
  get_om
fi

$CWD/om --env $CWD/env-fix.yml delete-installation --force
rm -rf $CWD/*-fix.yml $CWD/terraform-creds.yml $CWD/jq $CWD/om $CWD/pivnet $CWD/kubectl $CWD/pks $CWD/tkgi $CWD/downloaded-files $CWD/*.cert $CWD/remote-uaac-shell.sh $CWD/terraform-output.json

trap : 0

echo >&2 '
************
*** DONE ***
************
'
