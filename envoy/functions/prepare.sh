#!/bin/sh

function PrepareGatewayInfra() {
  oc apply -f "${GATEWAY_DIR}/yamls/001-gateway-config-main.yaml" -n ${POC_NAMESPACE}
  oc apply -f "${GATEWAY_DIR}/yamls/002-infra.yaml" -n ${POC_NAMESPACE}
}
