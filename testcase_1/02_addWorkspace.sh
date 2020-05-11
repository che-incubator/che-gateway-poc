#!/bin/sh

#set -x
set -e

. "$( dirname "${0}" )/../env.sh"

## random workspace suffix
WS_SUFFIX=$( head /dev/urandom | tr -dc a-z0-9 | head -c 5 ; echo '' )
WS="che-workspace-${WS_SUFFIX}"
echo ${WS} >> ${WORKSPACES_DB}


## create workspace namespace
oc create namespace ${WS}


## create workspace objects
sed "s/{{WORKSPACE}}/${WS}/g" ${YAMLS_DIR}/workspace.yaml_template | oc apply -f -

# reconfigure router and do live-reload
fullReconfig

## print all workspaces urls
echo "http://${HOST}"
for WS in $( cat ${WORKSPACES_DB} ) ; do
  echo "http://${HOST}/${WS}"
done

sleep 1

echo "${WS},${HOST},/${WS}" >> ${URLS_CSV}