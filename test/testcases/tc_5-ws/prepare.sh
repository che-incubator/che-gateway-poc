#!/bin/sh

function prepareTestcase() {
  # prepare 500 workspaces
  for I in {001..500}; do
    local WS="ws-${I}"
    prepareNewWorkspace ${WS} "${POC_WSNAMESPACE}-${WS}"
  done
  createPreparedWorkspacesInfra
  writeTestAndFlushPreparedWorkspaces
}
