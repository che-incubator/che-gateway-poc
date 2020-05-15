#!/bin/sh

function FullGatewayReconfig() {
    mkdir -p ${CONFIGMAPS_DIR}
    rm -Rf ${CONFIGMAPS_DIR}/*

    NAME=0
    while IFS=, read -r WS_PATH SERVICE; do
        CONFIG_MAP="
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: ws-$NAME
            labels:
                che-config-role: gateway
          data:
            ws-$NAME: |
              location /${WS_PATH} {
                proxy_pass http://${SERVICE};
                proxy_cookie_path \$uri /${WS_PATH}\$uri;
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection \$connection_upgrade;
              }
        "
        echo "${CONFIG_MAP}" | oc apply -n ${POC_NAMESPACE} -f -
        NAME=$(($NAME + 1))
    done < ${WORKSPACES_DB}    
}
