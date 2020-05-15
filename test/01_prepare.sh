#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"

prepareWorkdir
prepareBaseInfra

PrepareGatewayInfra
prepareTestcase

printWorkspaces
