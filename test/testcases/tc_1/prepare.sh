#!/bin/sh

function prepareTestcase() {
  # prepare 10 workspaces
  for I in {001..010}; do
    local WS="ws-${I}"
    prepareNewWorkspace ${WS}
  done

  # actualy create infrastructure for all
  createPreparedWorkspacesInfra

  # test only with 5 for now
  writeTestAndFlushPreparedWorkspaces 5
}
