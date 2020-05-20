#!/bin/sh

function FullGatewayReconfig() {
  ROUTER_MAP=""
  BACKENDS=""
  while IFS=, read -r URL_PATH SERVICE; do
    BACKENDS="${BACKENDS}backend ${SERVICE}
          cookie SERVERUSED insert indirect nocache
          http-request set-path %[path,regsub(^/${URL_PATH}/?,/)]
          server ${URL_PATH} ${SERVICE}:80

  "
    ROUTER_MAP="/${URL_PATH} ${SERVICE}
        ${ROUTER_MAP}"
  done < ${WORKSPACES_DB}

  echo "
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: haproxy-config
      labels:
        che-config-role: gateway
    data:
      cherouter.map: |
        ${ROUTER_MAP}
      backends.cfg: |
        ${BACKENDS}
  " | oc apply -n ${POC_NAMESPACE} -f -
}
