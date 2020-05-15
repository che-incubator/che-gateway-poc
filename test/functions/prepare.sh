#!/bin/sh

function prepareWorkdir() {
  echo "${WORKDIR}"
  rm -rf ${WORKDIR} && mkdir -p ${WORKDIR}
  echo "name,host,path" > ${URLS_CSV}
  touch "${WORKSPACES_DB}"
}

function prepareBaseInfra() {
  oc new-project ${POC_NAMESPACE}
  oc apply -f ${YAMLS_DIR}/infra.yaml -n ${POC_NAMESPACE}
  sed "s/{{NAME}}/che/g" ${YAMLS_DIR}/chepod.yaml_template | oc apply -n ${POC_NAMESPACE} -f -
  sed "s/{{HOST}}/${HOST}/g" ${YAMLS_DIR}/openshift.yaml_template | oc apply -n ${POC_NAMESPACE} -f -

  # add Che to tested URLs
  echo "che,${HOST}," >> ${URLS_CSV}

  echo "http://${HOST}"
}

function parseArgs() {
  if [ -z ${GATEWAY} ]; then
    echo "no <GATEWAY> set"
    exit 1
  fi

  readonly GATEWAY_DIR="${BASE_DIR}/${GATEWAY}"
  if [ ! -d "${GATEWAY_DIR}" ]; then
    echo "invalid gateway '${GATEWAY}'"
    exit 1
  fi

  if [ -z ${TESTCASE} ]; then
    echo "no <TESTCASE> set"
    exit 1
  fi

  readonly TESTCASE_DIR="${TESTCASES_DIR}/tc_${TESTCASE}"
  if [ ! -d "${TESTCASE_DIR}" ]; then
    echo "invalid TESTCASE '${TESTCASE}'"
    exit 1
  fi

  echo "using gateway '${GATEWAY}' and testcase '${TESTCASE}'"
}

function importTestFunctions() {
  . "${GATEWAY_DIR}/env.sh"
  . "${GATEWAY_DIR}/functions/prepare.sh"
  . "${GATEWAY_DIR}/functions/gateway.sh"

  . "${TESTCASES_DIR}/tc_${TESTCASE}/prepare.sh"
}
