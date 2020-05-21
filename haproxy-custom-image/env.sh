#!/bin/sh

CACHED_ROUTER_MAP="${WORKDIR}/cherouter.map"
HAPROXY_NWS_FILE="${WORKDIR}/nof_ws.txt"

function HaproxyGetNumberOfWorkspaces() {
    if [ ! -e ${HAPROXY_NWS_FILE} ]; then 
        echo 0
    else
        cat ${HAPROXY_NWS_FILE}
    fi
}

function HaproxySetNumberOfWorkspaces() {
    echo $1 > ${HAPROXY_NWS_FILE}
}
