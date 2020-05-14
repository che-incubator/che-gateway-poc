#!/bin/sh

function prepareWorkdir() {
  echo "${WORKDIR}"
  rm -rf ${WORKDIR} && mkdir -p ${WORKDIR}
}

function prepareInfra() {
  oc new-project ${POC_NAMESPACE}
  oc apply -f ${YAMLS_DIR}/infra.yaml -n ${POC_NAMESPACE}
  sed "s/{{HOST}}/${HOST}/g" ${YAMLS_DIR}/openshift.yaml_template | oc apply -n ${POC_NAMESPACE} -f -

  echo "name,host,path" > ${URLS_CSV}
  #echo "che,${HOST},/" >> ${URLS_CSV}

  echo "http://${HOST}"
}

function prepareService() {
  WS="${1}"
  NS="${2}"
  if [ -z ${WS} ] || [ -z ${NS} ]; then
    echo "have to pass '<workspace>' and '<namespace>'"
    exit 1
  fi

  echo "
---" >> ${WORKSPACES_PREPARE_YAML}
  sed "s/{{WORKSPACE}}/${WS}/g; s/{{NAMESPACE}}/${NS}/g" ${YAMLS_DIR}/service.yaml_template >> ${WORKSPACES_PREPARE_YAML}
}

function cleanPreparedServices() {
  rm -f ${WORKSPACES_PREPARE_YAML}
}

function createPreparedServices() {
  oc apply -f ${WORKSPACES_PREPARE_YAML} -n ${POC_NAMESPACE}
}

function writeServiceToTest() {
  WS="${1}"
  if [ -z ${WS} ]; then
    echo "have to pass '<workspace>'"
    exit 1
  fi

  echo "${WS},${HOST},/${WS}" >> ${URLS_CSV}
}

function writeServiceToConfig() {
  WS="${1}"
  if [ -z ${WS} ]; then
    echo "have to pass '<workspace>'"
    exit 1
  fi

  echo "${WS}" >> ${WORKSPACES_DB}
}
