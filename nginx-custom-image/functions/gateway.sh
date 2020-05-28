#!/bin/sh

function FullGatewayReconfig() {
    while IFS=, read -r WS_PATH SERVICE; do
      AddSingleRoute ${WS_PATH} ${SERVICE}
    done < ${WORKSPACES_DB}    
}

function AddSingleRoute() {
  WS_PATH=${1}
  SERVICE=${2}

  NUMBER_OF_WORKSPACES=`NginxGetNumberOfWorkspaces`
  N=$(($NUMBER_OF_WORKSPACES + 1))
  NAME=$(printf "%08d" $N)

  CONFIG_MAP="
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: ws-$NAME
      labels:
          che-config-role: gateway
    data:
      ws-$NAME: |
        location /${WS_PATH}/ {
          proxy_pass http://${SERVICE}/;
          proxy_cookie_path / /${WS_PATH}/;
          proxy_http_version 1.1;
          proxy_set_header Upgrade \$http_upgrade;
          proxy_set_header Connection \$connection_upgrade;
        }
        location /${WS_PATH} {
          proxy_pass http://${SERVICE}/;
          proxy_cookie_path / /${WS_PATH}/;
          proxy_http_version 1.1;
          proxy_set_header Upgrade \$http_upgrade;
          proxy_set_header Connection \$connection_upgrade;
        }
  "
  echo "${CONFIG_MAP}" | oc apply -n ${POC_NAMESPACE} -f -
  
  NUMBER_OF_WORKSPACES=$(($NUMBER_OF_WORKSPACES + 1))
  NginxSetNumberOfWorkspaces ${NUMBER_OF_WORKSPACES}
}