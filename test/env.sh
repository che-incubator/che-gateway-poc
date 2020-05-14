#!/bin/sh

GATEWAY=haproxy-scripted
TESTCASE=0
USER=mvala

POC_NAMESPACE="${USER}-singlehostpoc"
HOST="${POC_NAMESPACE}.apps-crc.testing"
#HOST="${POC_NAMESPACE}.apps.che-dev.x6e0.p1.openshiftapps.com"
YAMLS_DIR="$( dirname "${0}" )/yamls"
TESTCASES_DIR="$( dirname "${0}" )/testcases"

BASE_DIR="$( realpath "$( dirname "${0}" )/.." )"
WORKDIR="$( dirname "${0}" )/workdir"
WORKSPACES_DB="${WORKDIR}/workspaces.db"
URLS_CSV="${WORKDIR}/urls.csv"
WORKSPACES_PREPARE_YAML=${WORKDIR}/workspaces.yaml_prep

#. "$( dirname "${0}" )/functions/cleanup.sh"
. "$( dirname "${0}" )/functions/prepare.sh"
. "$( dirname "${0}" )/functions/workspace.sh"
