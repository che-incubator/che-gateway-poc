#!/bin/sh

NGINX_NWS_FILE="${WORKDIR}/nof_ws.txt"

function NginxGetNumberOfWorkspaces() {
    if [ ! -e ${NGINX_NWS_FILE} ]; then 
        echo 0
    else
        cat ${NGINX_NWS_FILE}
    fi
}

function NginxSetNumberOfWorkspaces() {
    echo $1 > ${NGINX_NWS_FILE}
}
