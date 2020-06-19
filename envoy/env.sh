#!/bin sh

ENVOY_BACKENDS_CFG="${WORKDIR}/workspaces.csv"
ENVOY_NWS_FILE="${WORKDIR}/nof_ws.txt"

function EnvoyGetNumberOfWorkspaces() {
    if [ ! -e ${ENVOY_NWS_FILE} ]; then 
        echo 0
    else
        cat ${ENVOYT_NWS_FILE}
    fi
}

function EnvoySetNumberOfWorkspaces() {
    echo $1 > ${ENVOY_NWS_FILE}
}

