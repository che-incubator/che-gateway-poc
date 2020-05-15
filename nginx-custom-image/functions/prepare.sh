#!/bin/sh

function PrepareGatewayInfra() {
  oc apply -f "${GATEWAY_DIR}/yamls/001-rbac.yaml" -n ${POC_NAMESPACE}
  oc apply -f "${GATEWAY_DIR}/yamls/002-gateway-config-main.yaml" -n ${POC_NAMESPACE}
  oc apply -f "${GATEWAY_DIR}/yamls/003-infra.yaml" -n ${POC_NAMESPACE}
}
