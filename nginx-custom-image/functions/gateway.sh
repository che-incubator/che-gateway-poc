#!/bin/sh

function FullGatewayReconfig() {
    mkdir -p CONFIGMAPS_DIR
    rm -Rf CONFIGMAPS_DIR/*

    NAME=0
    while IFS=, read -r PATH SERVICE; do
        CONFIG_MAP="
          apiVersion: v1
          kind: ConfigMap
          metatada:
            name: ws-$NAME
            labels:
                che-config-role: gateway
          data:
            ws-$NAME: |
              location ${PATH} {
                proxy_pass http://${SERVICE};
            }
        "
        echo "${CONFIG_MAP}" | oc apply -n ${POC_NAMESPACE} -f -
        NAME=$(($NAME + 1))
    done < ${WORKSPACES_DB}    
}
