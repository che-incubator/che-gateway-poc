#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"
parseArgs
importTestFunctions

set -x

prepareWorkdir
prepareBaseInfra

PrepareGatewayInfra
prepareTestcase
