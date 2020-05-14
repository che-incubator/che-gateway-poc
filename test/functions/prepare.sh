#!/bin/sh

function prepareWorkdir() {
  echo "${WORKDIR}"
  rm -rf ${WORKDIR} && mkdir -p ${WORKDIR}
  echo "name,host,path" > ${URLS_CSV}
}

function prepareBaseInfra() {
  oc new-project ${POC_NAMESPACE_MAIN}
  oc apply -f ${YAMLS_DIR}/infra.yaml -n ${POC_NAMESPACE_MAIN}
  sed "s/{{NAME}}/che/g" ${YAMLS_DIR}/chepod.yaml_template | oc apply -n ${POC_NAMESPACE_MAIN} -f -
  sed "s/{{HOST}}/${HOST}/g" ${YAMLS_DIR}/openshift.yaml_template | oc apply -n ${POC_NAMESPACE_MAIN} -f -

  # add Che to tested URLs
  echo "che,${HOST},/" >> ${URLS_CSV}

  echo "http://${HOST}"
}

function parseArgs() {
  if [ -z ${GATEWAY} ]; then
    GATEWAY=${1}
    if [ -z ${GATEWAY} ]; then
      echo "no <GATEWAY> set"
      exit 1
    fi
  fi
  GATEWAY="${BASE_DIR}/${GATEWAY}"
  if [ ! -d "${GATEWAY}" ]; then
    echo "invalid gateway '${GATEWAY}'"
    exit 1
  fi


  if [ -z ${TESTCASE} ]; then
    TESTCASE=${2}
    if [ -z ${TESTCASE} ]; then
      echo "no <TESTCASE> set"
      exit 1
    fi
  fi
  TESTCASE_DIR="${GATEWAY}/tc_${TESTCASE}"
  if [ ! -d "${TESTCASE_DIR}" ]; then
    echo "invalid TESTCASE '${TESTCASE}'"
    exit 1
  fi
}

function importTestFunctions() {
  . "${GATEWAY}/env.sh"
  . "${GATEWAY}/functions/prepare.sh"
  . "${GATEWAY}/functions/gateway.sh"

  . "${TESTCASES_DIR}/tc_${TESTCASE}/prepare.sh"
}
