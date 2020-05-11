#!/bin/sh

function prepareWorkdir() {
  echo ${WORKDIR}
  rm -f ${WORKDIR} && mkdir -p ${WORKDIR}
}

function prepareInfra() {
  oc new-project ${CHE_NAMESPACE}
  oc apply -f ${YAMLS_DIR}/infra.yaml -n ${CHE_NAMESPACE}
  sed "s/{{HOST}}/${HOST}/g" ${YAMLS_DIR}/openshift.yaml_template | oc apply -n ${CHE_NAMESPACE} -f -

  echo "name,host,path" > ${URLS_CSV}
  echo "che,${HOST},/" >> ${URLS_CSV}

  echo "http://${HOST}"
}
