#!/bin/sh

function FullGatewayReconfig() {
  ROUTER_MAP=""
  BACKENDS=""
  
  touch ${CACHED_ROUTER_MAP}

  while IFS=, read -r URL_PATH SERVICE; do
    echo "/${URL_PATH} ${SERVICE}" >> ${CACHED_ROUTER_MAP}
    addWorkspace "${URL_PATH}" "${SERVICE}"
  done < ${WORKSPACES_DB}

  regenerateCheRouterMap
}

function AddSingleRoute() {
  URL_PATH=${1}
  SERVICE=${2}

  addWorkspace "${URL_PATH}" "${SERVICE}"

  echo "/${URL_PATH} ${SERVICE}" >> ${CACHED_ROUTER_MAP}
  regenerateCheRouterMap
}

function addWorkspace() {
  URL_PATH=${1}
  SERVICE=${2}

  NUMBER_OF_WORKSPACES=`HaproxyGetNumberOfWorkspaces`
  N=$(($NUMBER_OF_WORKSPACES + 1))
  ID=$(printf "%08d" $N)

  echo "
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: ws-${ID}
      labels:
        che-config-role: gateway
    data:
      backend-${ID}.cfg: |
        backend ${SERVICE}
          cookie SERVERUSED insert indirect nocache
          http-request set-path %[path,regsub(^/${URL_PATH}/?,/)]
          server ${URL_PATH} ${SERVICE}:80
  " | oc apply -n ${POC_NAMESPACE} -f -

  NUMBER_OF_WORKSPACES=$(($NUMBER_OF_WORKSPACES + 1))
  HaproxySetNumberOfWorkspaces ${NUMBER_OF_WORKSPACES}
}

function regenerateCheRouterMap() {
  oc create configmap cherouter-map -n ${POC_NAMESPACE} --from-file=cherouter.map=${CACHED_ROUTER_MAP} -o json --dry-run | \
    jq '. * {"metadata": {"labels": {"che-config-role": "gateway"}}}' | oc apply -f -
}