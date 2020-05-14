#!/bin/sh

#set -x
set -e

. "$( dirname "${0}" )/../env.sh"

## random workspace suffix
WS_SUFFIX=$( head /dev/urandom | tr -dc a-z0-9 | head -c 5 ; echo '' )
WS="ws-${WS_SUFFIX}"

cleanPreparedServices
prepareService "${WS}" "${POC_NAMESPACE}"
createPreparedServices

sleep 1

writeServiceToTest "${WS}"
writeServiceToConfig "${WS}"

## print all workspaces urls
echo "http://${HOST}"
for WS in $( cat ${WORKSPACES_DB} ) ; do
  echo "http://${HOST}/${WS}"
done
# reconfigure router and do live-reload
fullReconfig
