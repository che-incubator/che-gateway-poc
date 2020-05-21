#!/bin/sh

function FullGatewayReconfig() {
  genConfig
  reconfigRouter
  kickoffHaproxy
}

# $1 - URL_PATH
# $2 - SERVICE
function AddSingleRoute() {
  URL_PATH=${1}
  SERVICE=${2}

  # write route to backends config file
  echo "
backend ${SERVICE}
  cookie SERVERUSED insert indirect nocache
  http-request set-path %[path,regsub(^/${URL_PATH}/?,/)]
  server ${URL_PATH} ${SERVICE}:80
  " >> ${HAPROXY_BACKENDS_CFG}

  # write route to haproxy route map config file
  echo "/${URL_PATH} ${SERVICE}" >> ${HAPROXY_ROUTER_MAP}

  reconfigRouter
  kickoffHaproxy
}

## update haproxy configmap
# generate config to file haproxy.cfg and cherouter.map
function genConfig() {
  # first cleanup backends and route map
  rm -f "${HAPROXY_ROUTER_MAP}" && touch "${HAPROXY_ROUTER_MAP}"
  rm -f "${HAPROXY_BACKENDS_CFG}" && touch "${HAPROXY_BACKENDS_CFG}"

  # then add all routes one by one
  while IFS=, read -r URL_PATH SERVICE; do
    AddSingleRoute ${URL_PATH} ${SERVICE}
  done < ${WORKSPACES_DB}
}

function reconfigRouter() {
  GATEWAY_POD=$( oc get pods -o json -n ${POC_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-gateway )

  # update configmap
  oc create configmap haproxy-config --from-file ${HAPROXY_CFG} --from-file ${HAPROXY_ROUTER_MAP} --from-file ${HAPROXY_BACKENDS_CFG} -o yaml -n ${POC_NAMESPACE} --dry-run | oc replace -n ${POC_NAMESPACE} -f -
  # update gateway pod's random annotation to force configmap reload
  oc patch pod ${GATEWAY_POD} -n ${POC_NAMESPACE} --patch "{\"metadata\": {\"annotations\": {\"random\": \"${RANDOM}\"} } }"
}

function kickoffHaproxy() {
  GATEWAY_POD=$( oc get pods -o json -n ${POC_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-gateway )
  if ! oc wait --for=condition=ready --timeout=300s pod ${GATEWAY_POD} -n ${POC_NAMESPACE}; then
    echo "gateway pod ${GATEWAY_POD} is not ready after 5 minute waiting. Something is wrong so end here!"
    exit 1
  fi

  ## restart haproxy process
  oc exec ${GATEWAY_POD} -n ${POC_NAMESPACE} -c haproxy -- "/bin/sh" "-c" "kill -HUP 1"
}

function fullReconfig() {
  genConfig
  reconfigRouter
  kickoffHaproxy
}
