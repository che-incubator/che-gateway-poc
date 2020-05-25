#!/bin/sh

function prepareTestcase() {
  # prepare 30 workspaces
  for I in {001..030}; do
    local WS="ws-${I}"
    prepareNewWorkspace ${WS}
  done

  # actualy create infrastructure for all
  createPreparedWorkspacesInfra

  # test only with 25 for now, add rest in actions.sh
  writeTestAndFlushPreparedWorkspaces 25
}
