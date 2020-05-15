#!/bin/sh

GATEWAY=haproxy-scripted
TESTCASE=0

if [ -z ${USER} ]; then
  echo "\$USER variable is empty. You have to set it. It's used as prefix for created namespaces."
  exit 1
fi
echo "username '${USER}' will be used as prefix for namespaces"

POC_NAMESPACE="${USER}-singlehostpoc"
HOST="${POC_NAMESPACE}.apps-crc.testing"
#HOST="${POC_NAMESPACE}.apps.che-dev.x6e0.p1.openshiftapps.com"
YAMLS_DIR="$( dirname "${0}" )/yamls"

BASE_DIR="$( realpath "$( dirname "${0}" )/.." )"
TESTCASES_DIR="$( realpath "$( dirname "${0}" )/testcases" )"
REPORTS_DIR="$( realpath "$( dirname "${0}" )/reports" )"
WORKDIR="$( realpath "$( dirname "${0}" )/workdir" )"
WORKSPACES_DB="${WORKDIR}/workspaces.db"
URLS_CSV="${WORKDIR}/urls.csv"
WORKSPACES_PREPARE_YAML=${WORKDIR}/workspaces.yaml_prep

#. "$( dirname "${0}" )/functions/cleanup.sh"
. "$( dirname "${0}" )/functions/prepare.sh"
. "$( dirname "${0}" )/functions/workspace.sh"
. "$( dirname "${0}" )/functions/test.sh"
parseArgs
importTestFunctions

REPORT_DIR="${REPORTS_DIR}/${GATEWAY}_tc${TESTCASE}_$( date +%s )"
