#!/bin/sh

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
    NS="${POC_NAMESPACE_WSBASE}${WS}"
  else
    NS=${1}
  fi
  echo "creating ${WS} in ${NS}"

  # if namespace does not exist, create new namespace and che pod there
  if ! oc get namespaces | egrep "${NS} "; then
    oc create namespace "${NS}"
    sed "s/{{NAME}}/${NS}/g" ${YAMLS_DIR}/chepod.yaml_template | oc apply -n ${NS} -f -
  fi

  echo "
---" >> ${WORKSPACES_PREPARE_YAML}
  sed "s/{{WORKSPACE}}/${WS}/g; s/{{NAMESPACE}}/${NS}/g" ${YAMLS_DIR}/workspaceService.yaml_template >> ${WORKSPACES_PREPARE_YAML}
}

# $1 - namespace (optional)
function createRandomWorkspace() {
  NS=${1}

  ## random workspace suffix
  WS_SUFFIX=$( head /dev/urandom | tr -dc a-z0-9 | head -c 10 ; echo '' )
  WS="ws-${WS_SUFFIX}"
  prepareNewWorkspace ${WS} ${NS}
  markWorkspaceToTest ${WS} ${NS}
  writeWorkspaceToDb ${WS} "${WS}.${NS}.svc.cluster.local"
  createPreparedWorkspaces
  FullGatewayReconfig
}

function createPreparedWorkspaces() {
  oc apply -f ${WORKSPACES_PREPARE_YAML}
  rm -f ${WORKSPACES_PREPARE_YAML}
}

# $1 - name that is passed to che pod
# $2 - path
function markWorkspaceToTest() {
  NAME=${1}
  URL_PATH=${2}
  if [ -z ${NAME} ] || [ -z ${URL_PATH} ]; then
    echo "have to pass '<name>' and '<path>'"
    exit 1
  fi

  echo "${NAME},${HOST},/${URL_PATH}" >> ${URLS_CSV}
}

# $1 - path
# $2 - service name (e.g. cheworkspace-ws1.ws1.svc.cluster.local)
function writeWorkspaceToDb() {
  URL_PATH=${1}
  SERVICE_NAME=${2}

  if [ -z ${URL_PATH} ] || [ -z ${SERVICE_NAME} ]; then
    echo "have to pass '<path>' and '<service>'"
    exit 1
  fi

  echo "${URL_PATH},${SERVICE_NAME}" >> ${WORKSPACES_DB}
}
