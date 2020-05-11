#!/bin/sh

. "$( dirname "${0}" )/../env.sh"
prepareWorkdir
prepareInfra

WORKSPACES=100
if [ -n ${1} ]; then
  WORKSPACES=${1}
fi

function addWorkspaceService() {
  WS="${1}"
  sed "s/{{WORKSPACE}}/${WS}/g" service.yaml_template | oc apply -f -
  echo "${WS}" >> ${WORKSPACES_DB}
  echo "${WS},${HOST},/${WS}" >> ${URLS_CSV}
}

addWorkspaceService "ws-plus"
sed -i '/ws-plus/d' ${URLS_CSV}
sed -i '/ws-plus/d' ${WORKSPACES_DB}

for I in {001..100}; do
  addWorkspaceService "ws-${I}"
done

fullReconfig
