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
trap 'abort' 0
echo "Delete installtion of PKS on Azure"

$CWD/om --env $CWD/env-fix.yml delete-installation --force
rm -rf $CWD/*-fix.yml $CWD/terraform-creds.yml $CWD/jq $CWD/om $CWD/pivnet $CWD/downloaded-files $CWD/*.cert $CWD/terraform-output.json

trap : 0

echo >&2 '
************
*** DONE ***
************
'
