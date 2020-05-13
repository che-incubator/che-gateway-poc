#!/bin/sh

## update haproxy configmap
# generate config to file haproxy.cfg and cherouter.map
function genConfig() {
    WORKSPACES=$( cat ${WORKSPACES_DB} )

  if [ -n ${1} ]; then
    NAMESPACE=${1}
  fi

  BACKENDS=""
  rm -f ${HAPROXY_ROUTER_MAP}
  for WS in ${WORKSPACES}; do
    if [ -z ${NAMESPACE} ]; then
      NS=${WS}
    else
      NS=${NAMESPACE}
    fi
    BACKENDS="${BACKENDS}
backend ${WS}
  cookie SERVERUSED insert indirect nocache
  http-request set-path %[path,regsub(^/${WS}/?,/)]
  server ${WS} ${WS}:80
  "
  echo "/${WS} ${WS}" >> ${HAPROXY_ROUTER_MAP}
  done

  cat >${HAPROXY_CFG} <<EOL
global

defaults
  timeout connect 10s
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
  server server1 che:80
EOL
}

function reconfigRouter() {
  GATEWAY_POD=$( oc get pods -o json -n ${POC_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-gateway )

  # update configmap
  oc create configmap haproxy-config --from-file ${HAPROXY_CFG} --from-file ${HAPROXY_ROUTER_MAP} -o yaml -n ${POC_NAMESPACE} --dry-run | oc replace -n ${POC_NAMESPACE} -f -
  # update gateway pod's random annotation to force configmap reload
  oc patch pod ${GATEWAY_POD} --patch "{\"metadata\": {\"annotations\": {\"random\": \"${RANDOM}\"} } }"
}

function kickoffHaproxy() {
  if ! oc wait --for=condition=ready --timeout=300s pod ${GATEWAY_POD} -n ${POC_NAMESPACE}; then
    echo "gateway pod ${GATEWAY_POD} is not ready after 5 minute waiting. Something is wrong so end here!"
    exit 1
  fi

  ## restart haproxy process
  # list processes
  PROCESSES=$( oc exec ${GATEWAY_POD} -c controller -n ${POC_NAMESPACE} -- "ps" "-o" "pid,ppid,comm" | grep haproxy )
  readarray -t PROCESSES <<<"$PROCESSES"
  # find haproxy parent process, which has parent pid 0
  PATTERN='\s+[0-9]+\s+0\s+haproxy'
  for P in "${PROCESSES[@]}"; do
    if [[ $P =~ ${PATTERN} ]] ; then
      # found parent process
      PID=$( echo ${P} | awk '{print $1;}' )
      # SIGHUP signal to parent process
      oc exec ${GATEWAY_POD} -c controller -- "kill" "-HUP" "${PID}"
    fi
  done
}

function fullReconfig() {
  genConfig ${1}
  reconfigRouter
  kickoffHaproxy
}
