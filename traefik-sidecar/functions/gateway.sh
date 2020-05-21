#!/bin/sh

function FullGatewayReconfig() {
    while IFS=, read -r WS_PATH SERVICE; do
        AddSingleRoute ${WS_PATH} ${SERVICE}
    done < ${WORKSPACES_DB}    
}

function AddSingleRoute() {
    WS_PATH=${1}
    SERVICE=${2}

    N=$(($NUMBER_OF_WORKSPACES + 1))
    NAME=$(printf "%08d" $N)

    CONFIG_MAP="
        apiVersion: v1
        kind: ConfigMap
        metadata:
            name: ws-${NAME}
            labels:
                che-config-role: gateway
        data:
            ws-${NAME}.yml: |
                http:
                    routers:
                        ws_${NAME}:
                            rule: \"PathPrefix(\`/${WS_PATH}\`)\"
                            service: ws_${NAME}
                            middlewares: [\"ws_${NAME}\"]
                            priority: 2
                    services:
                        ws_${NAME}:
                            loadBalancer:
                                servers:
                                - url: 'http://${SERVICE}'
                    middlewares:
                        ws_${NAME}:
                            stripPrefix:
                                prefixes:
                                - \"/${WS_PATH}\"
    "
    echo "${CONFIG_MAP}" | oc apply -n ${POC_NAMESPACE} -f -
    NUMBER_OF_WORKSPACES=$(($NUMBER_OF_WORKSPACES + 1))
}
