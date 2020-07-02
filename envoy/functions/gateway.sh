#!/bin/sh

function FullGatewayReconfig() {
  genConfig
  reconfigure
}

function AddSingleRoute() {
  writeNewRoute ${1} ${2}
  reconfigure
}

# $1 - URL_PATH
# $2 - SERVICE
function writeNewRoute() {
  URL_PATH=${1}
  SERVICE=${2}
  echo "/${URL_PATH},${SERVICE}" >> ${ENVOY_BACKENDS_CFG}
}

## update haproxy configmap
# generate config to file haproxy.cfg and cherouter.map
function genConfig() {
  # first cleanup backends
  rm -f "${ENVOY_BACKENDS_CFG}" && touch "${ENVOY_BACKENDS_CFG}"

  # then add all routes one by one
  while IFS=, read -r URL_PATH SERVICE; do
    writeNewRoute ${URL_PATH} ${SERVICE}
  done < ${WORKSPACES_DB}
}

function reconfigure() {
  CONTROL_POD=$( oc get pods -o json -n ${POC_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-envoy-control )

  # update configmap
  oc create configmap gateway-workspaces --from-file ${ENVOY_BACKENDS_CFG} -o yaml -n ${POC_NAMESPACE} --dry-run | oc replace -n ${POC_NAMESPACE} -f -
  # update gateway pod's random annotation to force configmap reload
  oc patch pod ${CONTROL_POD} -n ${POC_NAMESPACE} --patch "{\"metadata\": {\"annotations\": {\"random\": \"${RANDOM}\"} } }"
}
