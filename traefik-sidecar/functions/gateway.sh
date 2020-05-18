#!/bin/sh

function FullGatewayReconfig() {
    NAME=0
    while IFS=, read -r WS_PATH SERVICE; do
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
        NAME=$(($NAME + 1))
    done < ${WORKSPACES_DB}    
}
