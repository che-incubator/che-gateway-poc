#!/bin/sh

function PrepareGatewayInfra() {
  oc apply -f "${GATEWAY}/yamls/infra.yaml" -n ${POC_NAMESPACE_MAIN}
}
