#!/bin/sh

function prepareTestcase() {
  # prepare 26 workspaces
  for N in {001..005}; do
    for I in {001..005}; do
      local WS="ws-${I}"
      prepareNewWorkspace ${WS} "${POC_WSNAMESPACE}-${N}"
    done
  done
  for I in {001..005}; do
    local WS="ws-${I}"
    prepareNewWorkspace ${WS} "${POC_WSNAMESPACE}-extra"
  done

  # actualy create infrastructure for all
  createPreparedWorkspacesInfra

  # test only with 25 for now. add last one in actions.sh
  writeTestAndFlushPreparedWorkspaces 25
}
