#!/bin/sh

POC_NAMESPACE="${USER}-singlehostpoc"
HOST="${POC_NAMESPACE}.apps-crc.testing"
YAMLS_DIR="$( dirname "${0}" )/../yamls"

WORKDIR="$( dirname "${0}" )/workdir"
HAPROXY_CFG="${WORKDIR}/haproxy.cfg"
WORKSPACES_DB="${WORKDIR}/workspaces.db"
URLS_CSV="${WORKDIR}/urls.csv"
WORKSPACES_PREPARE_YAML=${WORKDIR}/workspaces.yaml_prepared

. "$( dirname "${0}" )/../genConfig.sh"
. "$( dirname "${0}" )/../cleanup.sh"
. "$( dirname "${0}" )/../prepare.sh"
