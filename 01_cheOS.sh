#!/bin/sh

#set -x

CHE_NAMESPACE=che3

oc new-project ${CHE_NAMESPACE}
oc apply -f infra.yaml -n ${CHE_NAMESPACE}
oc apply -f openshift.yaml -n ${CHE_NAMESPACE}

rm -f workspaces.db
rm -f haproxy.cfg

echo "http://test-che-gateway.apps-crc.testing"
