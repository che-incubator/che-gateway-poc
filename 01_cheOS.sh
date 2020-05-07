#!/bin/sh

#set -x

CHE_NAMESPACE=che
HOST=test-che-gateway.apps-crc.testing

oc new-project ${CHE_NAMESPACE}
oc apply -f infra.yaml -n ${CHE_NAMESPACE}
sed "s/{{HOST}}/${HOST}/g" openshift.yaml_template | oc apply -n ${CHE_NAMESPACE} -f -

rm -f haproxy.cfg
rm -f workspaces.db
rm -f urls.csv
echo "name,host,path" > urls.csv
echo "che,${HOST},/" >> urls.csv

echo "http://${HOST}"
