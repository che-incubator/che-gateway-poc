#!/bin/sh

function cleanup() {
  PROJECTS=$( oc get projects -o json | jq -r ".items[].metadata.name | select(. | startswith(\""${POC_NAMESPACE}"\"))" )
  if [ -z ${PROJECTS} ]; then
    echo "no projects that starts with '${POC_NAMESPACE}' found"
    exit 1
  fi
  COMMAND="oc delete projects"
  for P in ${PROJECTS}; do
    if [[ ${P} != ${USER}* ]]; then
      echo "you should not touch namespaces that does not start with your username"
      echo "change this script if you're brave enough"
      exit 1
    fi
    COMMAND="${COMMAND} ${P}"
  done
  echo ${COMMAND}
  ${COMMAND}

  rm -rf ${WORKDIR}
}
