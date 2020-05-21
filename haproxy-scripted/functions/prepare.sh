#!/bin/sh

function PrepareGatewayInfra() {
  oc apply -f "${GATEWAY_DIR}/yamls/infra.yaml" -n ${POC_NAMESPACE}

  cat >${HAPROXY_CFG} <<EOL
global

defaults
  timeout connect 5s
  timeout client 30s
  timeout server 30s
  mode http

frontend che
  bind :8080

  use_backend %[path,map_beg(/usr/local/etc/haproxy/cherouter.map)]

  default_backend che-server

backend che-server
  cookie SERVERUSED insert indirect nocache
  server che che:80
EOL
}
