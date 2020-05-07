#!/bin/sh

#set -x
set -e

CHE_NAMESPACE=che
HOST=test-che-gateway.apps-crc.testing
GATEWAY_POD=$( oc get pods -o json -n ${CHE_NAMESPACE} | jq '.items[].metadata.name' -r | grep che-gateway )

## random workspace suffix
WS_SUFFIX=$( head /dev/urandom | tr -dc a-z0-9 | head -c 5 ; echo '' )
WS="che-workspace-${WS_SUFFIX}"
echo ${WS} >> workspaces.db


## create workspace namespace
oc create namespace ${WS}


## create workspace objects
sed "s/{{WORKSPACE}}/${WS}/g" workspace.yaml_template | oc apply -f -


## update haproxy configmap
# generate config to file haproxy.cfg
sh genConfig.sh
# update configmap
oc create configmap haproxy-config --from-file haproxy.cfg -o yaml -n ${CHE_NAMESPACE} --dry-run | oc replace -n ${CHE_NAMESPACE} -f -
# update gateway pod's random annotation to force configmap reload
oc patch pod ${GATEWAY_POD} --patch "{\"metadata\": {\"annotations\": {\"random\": \"${RANDOM}\"} } }"


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


## print all workspaces urls
echo "http://test-che-gateway.apps-crc.testing"
for WS in $( cat workspaces.db ) ; do
  echo "http://test-che-gateway.apps-crc.testing/${WS}"
done

sleep 1

echo "${WS},${HOST},/${WS}" >> urls.csv
