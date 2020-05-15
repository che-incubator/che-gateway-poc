#!/bin/sh

function prepareTestcase() {
  createRandomWorkspace

  # for I in {001..003}; do
  #   local WS="ws-${I}"
  #   local URL_PATH="${WS}"
  #   prepareNewWorkspace "${WS}"
  #   markWorkspaceToTest "${POC_NAMESPACE}" "${WS}"
  #   writeWorkspaceToDb "${WS}" "${WS}"
  # done

  # for I in {001..003}; do
  #   local WS="ws-${I}"
  #   local NS="${POC_NAMESPACE}-workspaces1"
  #   local URL_PATH="${NS}-${WS}"
  #   prepareNewWorkspace "${WS}" "${NS}"
  #   markWorkspaceToTest "${NS}" "${URL_PATH}"
  #   writeWorkspaceToDb "${URL_PATH}" "${WS}.${NS}.svc.cluster.local"
  # done

  # createPreparedWorkspaces

  FullGatewayReconfig
}
