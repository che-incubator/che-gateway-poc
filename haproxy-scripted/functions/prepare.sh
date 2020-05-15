#!/bin/sh

function PrepareGatewayInfra() {
  oc apply -f "${GATEWAY_DIR}/yamls/infra.yaml" -n ${POC_NAMESPACE}
}
