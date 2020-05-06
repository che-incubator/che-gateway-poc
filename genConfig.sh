#!/bin/sh

WORKSPACES=$( cat workspaces.db )

FRONTENDS=""
BACKENDS=""
for WS in ${WORKSPACES}; do
  FRONTENDS="${FRONTENDS}
  acl is_${WS} path_beg /${WS}
  use_backend ${WS} if is_${WS}
  "

  BACKENDS="${BACKENDS}
backend ${WS}
  cookie SERVERUSED insert indirect nocache
  http-request set-path %[path,regsub(^/${WS}/?,/)]
  server ${WS} ${WS}.${WS}:80
  "
done

cat >haproxy.cfg <<EOL
global
  debug

defaults
  timeout connect 10s
  timeout client 30s
  timeout server 30s
  mode http

frontend che
  bind :8080

  ${FRONTENDS}

  default_backend che-server

${BACKENDS}

backend che-server
  cookie SERVERUSED insert indirect nocache
  server server1 che:80
EOL
