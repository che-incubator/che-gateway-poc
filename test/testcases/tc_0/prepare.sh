#!/bin/sh

function prepareTestcase() {
  createRandomWorkspace

  for I in {001..010}; do
    WS="ws-${I}"
    URL_PATH="${WS}"
    prepareNewWorkspace "${WS}"
    markWorkspaceToTest "${POC_NAMESPACE}" "${WS}"
    writeWorkspaceToDb "${WS}" "${WS}"
  done

  createPreparedWorkspaces

  FullGatewayReconfig
}
