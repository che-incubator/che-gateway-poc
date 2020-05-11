#!/bin/sh

## update haproxy configmap
# generate config to file haproxy.cfg
function genConfig() {
  WORKSPACES=$( cat ${WORKSPACES_DB} )

  if [ -n ${1} ]; then
    NAMESPACE=${1}
  fi

  FRONTENDS=""
  BACKENDS=""
  for WS in ${WORKSPACES}; do
    FRONTENDS="${FRONTENDS}
  acl is_${WS} path_beg /${WS}
  use_backend ${WS} if is_${WS}
    "

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
  done

  cat >${HAPROXY_CFG} <<EOL
global
  debug

defaults
  timeout connect 10s
  timeout client 30s
  timeout server 30s
  mode http

frontend che
  bind :8080

  ${FRONTENDS}

  default_backend che-server

${BACKENDS}

backend che-server
  cookie SERVERUSED insert indirect nocache
  server server1 che:80
EOL
}

function reconfigRouter() {
  GATEWAY_POD=$( oc get pods -o json -n ${CHE_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-gateway )
  
  # update configmap
  oc create configmap haproxy-config --from-file ${HAPROXY_CFG} -o yaml -n ${CHE_NAMESPACE} --dry-run | oc replace -n ${CHE_NAMESPACE} -f -
  # update gateway pod's random annotation to force configmap reload
  oc patch pod ${GATEWAY_POD} --patch "{\"metadata\": {\"annotations\": {\"random\": \"${RANDOM}\"} } }"
}

function kickoffHaproxy() {
  ## restart haproxy process
  # list processes
  PROCESSES=$( oc exec ${GATEWAY_POD} -c controller -n ${CHE_NAMESPACE} -- "ps" "-o" "pid,ppid,comm" | grep haproxy )
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
