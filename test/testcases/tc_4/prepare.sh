#!/bin/sh

function prepareTestcase() {
  # prepare 100 workspaces
  for I in {001..100}; do
    local WS="ws-${I}"
    prepareNewWorkspace ${WS} "${POC_WSNAMESPACE}-${WS}"
  done
  createPreparedWorkspacesInfra
  writeTestAndFlushPreparedWorkspaces
}
