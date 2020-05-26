#!/bin/sh

function PrepareGatewayInfra() {
  oc apply -f "${GATEWAY_DIR}/yamls/001-rbac.yaml" -n ${POC_NAMESPACE}
  oc apply -f "${GATEWAY_DIR}/yamls/002-crds.yaml" -n ${POC_NAMESPACE}
  cat "${GATEWAY_DIR}/yamls/003-infra.yaml" | sed -E "s/\{\{POC_NAMESPACE\}\}/${POC_NAMESPACE}/" | oc apply -n ${POC_NAMESPACE} -f -
}
