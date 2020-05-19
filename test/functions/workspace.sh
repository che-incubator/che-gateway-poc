#!/bin/sh

#TODO: prepare namespace function

# $1 - workspace
# $2 - namespace (optional)
function prepareNewWorkspace() {
  WS=${1}

  if [ -z ${WS} ]; then
    echo "you must <workspace>"
    exit 1
  fi

  # when no namespace received, use workspace name as a part of namespace name
  if [ -z ${2} ]; then
    NS="${POC_NAMESPACE}-${1}"
  else
    NS="${2}"
  fi
  echo "preparing ${WS} in ${NS}"
  echo "${WS} ${NS}" >> ${WORKSPACES_PREPARED}
}

# $1 - workspace
function createWorkspace() {
  WS=${1}
  if [ -z ${WS} ]; then
    echo "you must <workspace>"
    exit 1
  fi

  prepareNewWorkspace ${WS}
  createPreparedWorkspacesInfra 1

  writeTestAndFlushPreparedWorkspaces 1
}

# $1 - number of workspaces that should be created
function createPreparedWorkspacesInfra() {
  WORKSPACE_COUNT=${1:-9999}
  head -n ${WORKSPACE_COUNT} ${WORKSPACES_PREPARED} | while read -r WS NS; do
    echo "about to create ${WS} in ${NS}"
    #TODO: let caller prepare the namespace so this is not called gazzilion times
    #if namespace does not exist, create new namespace and che pod there
    if ! oc get projects | egrep "${NS} "; then
      oc new-project "${NS}"
      sed "s/{{NAME}}/${NS}/g" ${YAMLS_DIR}/chepod.yaml_template | oc apply -n ${NS} -f -
    fi

    echo "
---" >> ${WORKSPACES_PREPARE_YAML}
    sed "s/{{WORKSPACE}}/${WS}/g; s/{{NAMESPACE}}/${NS}/g" ${YAMLS_DIR}/workspaceService.yaml_template >> ${WORKSPACES_PREPARE_YAML}
  done

  oc apply -f ${WORKSPACES_PREPARE_YAML}
  rm -f ${WORKSPACES_PREPARE_YAML}
}

# $1 - namespace (optional)
function createRandomWorkspace() {
  NS=${1}

  ## random workspace suffix
  WS_SUFFIX=$( head /dev/urandom | tr -dc a-z0-9 | head -c 10 ; echo '' )
  WS="ws-${WS_SUFFIX}"\

  createWorkspace ${WS} ${NS}
}

function markPreparedWorkspacesToTest() {
  WORKSPACE_COUNT=${1:-9999}
  head -n ${WORKSPACE_COUNT} ${WORKSPACES_PREPARED} | while read -r WS NS; do
    echo "${NS},${HOST},/${WS}-${NS}" >> ${URLS_CSV}
  done
}

function writePreparedWorkspacesToDb() {
  WORKSPACE_COUNT=${1:-9999}
  head -n ${WORKSPACE_COUNT} ${WORKSPACES_PREPARED} | while read -r WS NS; do
    echo "${WS}-${NS},${WS}.${NS}.svc.cluster.local" >> ${WORKSPACES_DB}
  done
}

function flushPreparedWorkspaces() {
  WORKSPACE_COUNT=${1:-9999}
  sed -i 1,${WORKSPACE_COUNT}d ${WORKSPACES_PREPARED}
}

function writeTestAndFlushPreparedWorkspaces() {
  WORKSPACE_COUNT=${1:-9999}
  writePreparedWorkspacesToDb ${WORKSPACE_COUNT}
  FullGatewayReconfig
  markPreparedWorkspacesToTest ${WORKSPACE_COUNT}
  flushPreparedWorkspaces ${WORKSPACE_COUNT}
}

function printWorkspaces() {
  while IFS=, read -r NAME URL_HOST URL_PATH; do
    echo "${NAME} -> http://${URL_HOST}${URL_PATH}"
  done < ${URLS_CSV}
}
