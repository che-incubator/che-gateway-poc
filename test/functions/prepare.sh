#!/bin/sh

function prepareWorkdir() {
  echo "${WORKDIR}"
  rm -rf ${WORKDIR} && mkdir -p ${WORKDIR}
  echo "name,host,path" > ${URLS_CSV}
  touch "${WORKSPACES_DB}"
  cp "${TESTCASES_DIR}/tc_${TESTCASE}/test.jmx" ${JMETER_TEST_FILE}
  if [ -f "${TESTCASES_DIR}/tc_${TESTCASE}/params.csv" ]; then
    cp "${TESTCASES_DIR}/tc_${TESTCASE}/params.csv" ${TEST_PARAMS_FILE}
  fi
  mkdir -p ${REPORTS_DIR}
}

# $1 - the name of the template to use for the workspace pod - default is the value of POD_TEMPLATE_FILE variable
function prepareBaseInfra() {
  local POD_TEMPLATE=${1:-${POD_TEMPLATE_FILE}}
  # the projects may linger on from previous runs, so let's wait until OpenShift gets its act together..
  until oc new-project ${POC_NAMESPACE}; do echo "Retrying..."; sleep 1; done
  oc apply -f ${YAMLS_DIR}/infra.yaml -n ${POC_NAMESPACE}
  sed "s/{{NAME}}/che/g" ${YAMLS_DIR}/${POD_TEMPLATE} | oc apply -n ${POC_NAMESPACE} -f -
  sed "s/{{HOST}}/${HOST}/g" ${YAMLS_DIR}/openshift.yaml_template | oc apply -n ${POC_NAMESPACE} -f -

  # project for workspaces
  #until oc new-project ${POC_WSNAMESPACE}; do echo "Retrying..."; sleep 1; done
  #sed "s/{{NAME}}/${POC_WSNAMESPACE}/g;s/64Mi/1024Mi/g;s/100m/2/g" ${YAMLS_DIR}/${POD_TEMPLATE} | oc apply -n ${POC_WSNAMESPACE} -f -

  # write all current project into the file so we don't have to re-request it later
  oc get projects > ${OS_PROJECTS}

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
