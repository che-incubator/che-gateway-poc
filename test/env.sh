#!/bin/sh

readonly GATEWAY=${1:-${GATEWAY:-haproxy-scripted}}
readonly TESTCASE=${2:-${TESTCASE:-0}}

if [ -z ${USER} ]; then
  echo "\$USER variable is empty. You have to set it. It's used as prefix for created namespaces."
  exit 1
fi
echo "username '${USER}' will be used as prefix for namespaces"

readonly POC_NAMESPACE="${USER}-singlehostpoc"
readonly HOST="${POC_NAMESPACE}.apps-crc.testing"
#HOST="${POC_NAMESPACE}.apps.che-dev.x6e0.p1.openshiftapps.com"
readonly YAMLS_DIR="$( dirname "${0}" )/yamls"

readonly BASE_DIR="$( realpath "$( dirname "${0}" )/.." )"
readonly TESTCASES_DIR="$( realpath "$( dirname "${0}" )/testcases" )"
readonly REPORTS_DIR="$( realpath "$( dirname "${0}" )/reports" )"
readonly WORKDIR="$( realpath "$( dirname "${0}" )/workdir" )"
readonly WORKSPACES_DB="${WORKDIR}/workspaces.db"
readonly URLS_CSV="${WORKDIR}/urls.csv"
readonly WORKSPACES_PREPARE_YAML=${WORKDIR}/workspaces.yaml_prep

#. "$( dirname "${0}" )/functions/cleanup.sh"
. "$( dirname "${0}" )/functions/prepare.sh"
. "$( dirname "${0}" )/functions/workspace.sh"
. "$( dirname "${0}" )/functions/test.sh"
parseArgs "$@"
importTestFunctions

readonly REPORT_DIR="${REPORTS_DIR}/${GATEWAY}_tc${TESTCASE}_$( date +%s )"
