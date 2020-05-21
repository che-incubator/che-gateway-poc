#!/bin sh

TRAEFIK_NWS_FILE="${WORKDIR}/nof_ws.txt"

function TraefikGetNumberOfWorkspaces() {
    if [ ! -e ${TRAEFIK_NWS_FILE} ]; then 
        echo 0
    else
        cat ${TRAEFIK_NWS_FILE}
    fi
}

function TraefikSetNumberOfWorkspaces() {
    echo $1 > ${TRAEFIK_NWS_FILE}
}

