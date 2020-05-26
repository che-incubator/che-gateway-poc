#!/bin/sh

function FullGatewayReconfig() {
    NAME=0
    while IFS=, read -r WS_PATH SERVICE; do
      AddSingleRoute "${WS_PATH}" "${SERVICE}"
    done < ${WORKSPACES_DB}    
}

function AddSingleRoute() {
  WS_PATH=${1}
  SERVICE=${2}

  SERVICE_NAME=`echo ${SERVICE} | sed -E 's/([^.]+)\.([^.]+)\..*/\1/'`
  SERVICE_NAMESPACE=`echo ${SERVICE} | sed -E 's/([^.]+)\.([^.]+)\..*/\2/'`

  NUMBER_OF_WORKSPACES=`TraefikGetNumberOfWorkspaces`
  N=$(($NUMBER_OF_WORKSPACES + 1))
  NAME=$(printf "%08d" $N)

  MIDDLEWARE="
  apiVersion: traefik.containo.us/v1alpha1
  kind: Middleware
  metadata:
    name: ws-mw-${NAME}
  spec:
    stripPrefix:
      prefixes:
      - /${WS_PATH}
  "    
  ROUTE="
  apiVersion: traefik.containo.us/v1alpha1
  kind: IngressRoute
  metadata:
    name: ws-${NAME}
  spec:
    entryPoints:
    - web
    routes:
    - match: PathPrefix(\`/${WS_PATH}\`)
      kind: Rule
      priority: 2
      services:
      - name: ${SERVICE_NAME}
        namespace: ${SERVICE_NAMESPACE}
        port: 80
      middlewares:
      - name: ws-mw-${NAME}
        namespace: ${POC_NAMESPACE}
  "
    echo "${MIDDLEWARE}" | oc apply -n ${POC_NAMESPACE} -f -
    echo "${ROUTE}" | oc apply -n ${POC_NAMESPACE} -f -
    NUMBER_OF_WORKSPACES=$(($NUMBER_OF_WORKSPACES + 1))
    TraefikSetNumberOfWorkspaces $NUMBER_OF_WORKSPACES
}