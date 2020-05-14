#!/bin/sh

POC_NAMESPACE="${USER}-singlehostpoc"
#HOST="${POC_NAMESPACE}.apps-crc.testing"
HOST="${POC_NAMESPACE}.apps.che-dev.x6e0.p1.openshiftapps.com"
YAMLS_DIR="$( dirname "${0}" )/../yamls"

WORKDIR="$( dirname "${0}" )/workdir"
HAPROXY_CFG="${WORKDIR}/haproxy.cfg"
HAPROXY_ROUTER_MAP="${WORKDIR}/cherouter.map"
HAPROXY_PID="${WORKDIR}/haproxy.pid"
WORKSPACES_DB="${WORKDIR}/workspaces.db"
URLS_CSV="${WORKDIR}/urls.csv"
WORKSPACES_PREPARE_YAML=${WORKDIR}/workspaces.yaml_prepared

. "$( dirname "${0}" )/../genConfig.sh"
. "$( dirname "${0}" )/../cleanup.sh"
. "$( dirname "${0}" )/../prepare.sh"
