#!/bin/sh

. "$( dirname "${0}" )/../env.sh"

WS="ws-plus"
if ! grep -q ws-plus "${WORKSPACES_DB}"; then
  echo "adding 'ws-plus' ..."
  echo "${WS}" >> ${WORKSPACES_DB}
else
  echo "ws-plus is already there!"
  exit 1
fi

# reconfigure router and do live-reload
fullReconfig ${CHE_NAMESPACE}
echo "${WS},${HOST},/${WS}" >> ${URLS_CSV}
