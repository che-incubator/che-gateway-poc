#!/bin/sh

function prepareTestcase() {
  # prepare 50 workspaces, enough for 5 runs
  for I in {001..050}; do
    local WS="ws-${I}"
    prepareNewWorkspace ${WS}
  done

  # actualy create infrastructure for all
  createPreparedWorkspacesInfra

  # test only with 25 for now, add rest in actions.sh for 5 runs
  writeTestAndFlushPreparedWorkspaces 25
}
