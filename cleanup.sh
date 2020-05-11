#!/bin/sh

function cleanup() {
  PROJECTS=$( oc get projects -o json | jq -r '.items[].metadata.name | select(. | startswith("che"))' )
  COMMAND="oc delete projects"
  for P in ${PROJECTS}; do
    COMMAND="${COMMAND} ${P}"
  done
  echo ${COMMAND}
  $( ${COMMAND} )

  rm -rf ${WORKDIR}
}
