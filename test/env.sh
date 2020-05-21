#!/bin/sh

# GATEWAY and TESTCASE variables are taken with priority
# script arguments > env variables > defaults
readonly GATEWAY=${1:-${GATEWAY:-haproxy-scripted}}
readonly TESTCASE=${2:-${TESTCASE:-0}}

if [ -z ${USER} ]; then
  echo "\$USER variable is empty. You have to set it. It's used as prefix for created namespaces."
  exit 1
fi
echo "username '${USER}' will be used as prefix for namespaces"

readonly POC_NAMESPACE="${USER}-singlehostpoc"
readonly POC_WSNAMESPACE="${POC_NAMESPACE}-ws"
#readonly HOST="${POC_NAMESPACE}.apps-crc.testing"
readonly HOST="${POC_NAMESPACE}.apps.che-dev.x6e0.p1.openshiftapps.com"
readonly HOST_IP="$( getent hosts ${HOST} | head -n 1 | awk '{ print $1 }' )"
readonly YAMLS_DIR="$( dirname "${0}" )/yamls"

readonly BASE_DIR="$( realpath "$( dirname "${0}" )/.." )"
readonly TESTCASES_DIR="$( realpath "$( dirname "${0}" )/testcases" )"
readonly REPORTS_DIR="$( realpath "$( dirname "${0}" )/reports" )"
readonly WORKDIR="$( realpath "$( dirname "${0}" )/workdir" )"
readonly WORKSPACES_DB="${WORKDIR}/workspaces.db"
readonly URLS_CSV="${WORKDIR}/urls.csv"
readonly WORKSPACES_PREPARE_YAML=${WORKDIR}/workspaces.yaml_prep
readonly WORKSPACES_PREPARED=${WORKDIR}/workspaces_prepared
readonly JMETER_TEST_FILE=${WORKDIR}/test.jmx
readonly TEST_PARAMS_FILE=${WORKDIR}/params.csv
readonly TEST_STATS_FILE="${REPORTS_DIR}/${GATEWAY}_tc${TESTCASE}_stats_$( date +%s ).csv"
readonly OS_PROJECTS=${WORKDIR}/os_projects

#. "$( dirname "${0}" )/functions/cleanup.sh"
. "$( dirname "${0}" )/functions/prepare.sh"
. "$( dirname "${0}" )/functions/workspace.sh"
parseArgs "$@"
importTestFunctions
