#!/bin/sh

function FullGatewayReconfig() {
  genConfig
  reconfigRouter
  kickoffHaproxy
}

## update haproxy configmap
# generate config to file haproxy.cfg and cherouter.map
function genConfig() {
  BACKENDS=""
  rm -f "${HAPROXY_ROUTER_MAP}" && touch "${HAPROXY_ROUTER_MAP}"

  while IFS=, read -r URL_PATH SERVICE; do
    BACKENDS="${BACKENDS}
backend ${SERVICE}
  cookie SERVERUSED insert indirect nocache
  http-request set-path %[path,regsub(^/${URL_PATH}/?,/)]
  server ${URL_PATH} ${SERVICE}:80
  "
    echo "/${URL_PATH} ${SERVICE}" >> ${HAPROXY_ROUTER_MAP}
  done < ${WORKSPACES_DB}


  cat >${HAPROXY_CFG} <<EOL
global

defaults
  timeout connect 5s
  timeout client 30s
  timeout server 30s
  mode http

frontend che
  bind :8080

  use_backend %[path,map_beg(/usr/local/etc/haproxy/cherouter.map)]

  default_backend che-server

${BACKENDS}

backend che-server
  cookie SERVERUSED insert indirect nocache
  server che che:80
EOL
}

function reconfigRouter() {
  GATEWAY_POD=$( oc get pods -o json -n ${POC_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-gateway )

  # update configmap
  oc create configmap haproxy-config --from-file ${HAPROXY_CFG} --from-file ${HAPROXY_ROUTER_MAP} -o yaml -n ${POC_NAMESPACE} --dry-run | oc replace -n ${POC_NAMESPACE} -f -
  # update gateway pod's random annotation to force configmap reload
  oc patch pod ${GATEWAY_POD} -n ${POC_NAMESPACE} --patch "{\"metadata\": {\"annotations\": {\"random\": \"${RANDOM}\"} } }"
}

function findHaproxyPid() {
  PROCESSES=$( oc exec ${GATEWAY_POD} -c haproxy -n ${POC_NAMESPACE} -- "ls" "/proc" )
  for P in ${PROCESSES}; do
    if [[ "${P}" =~ ^[0-9]+$ ]]; then
      PID_STATUS=$( oc exec ${GATEWAY_POD} -c haproxy -n ${POC_NAMESPACE} -- "cat" "/proc/${P}/status" )
      #echo "${PID_STATUS}"
      if echo "${PID_STATUS}" | grep 'haproxy' > /dev/null && echo "${PID_STATUS}" | grep 'PPid' | grep 0 > /dev/null; then
        echo ${P} > ${HAPROXY_PID}
        return
      fi
    fi
  done
  echo "no haproxy process found. exit 1"
  exit 1
}

function kickoffHaproxy() {
  GATEWAY_POD=$( oc get pods -o json -n ${POC_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-gateway )
  if ! oc wait --for=condition=ready --timeout=300s pod ${GATEWAY_POD} -n ${POC_NAMESPACE}; then
    echo "gateway pod ${GATEWAY_POD} is not ready after 5 minute waiting. Something is wrong so end here!"
    exit 1
  fi

  ## restart haproxy process
  # list processes
  GATEWAY_POD=$( oc get pods -o json -n ${POC_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-gateway )
  if [ ! -f ${HAPROXY_PID} ]; then
    findHaproxyPid
  fi
  #set -x
  oc exec ${GATEWAY_POD} -n ${POC_NAMESPACE} -c haproxy -- "/bin/sh" "-c" "kill -HUP $( cat ${HAPROXY_PID} )"
  #set +x
}

function fullReconfig() {
  genConfig
  reconfigRouter
  kickoffHaproxy
}
