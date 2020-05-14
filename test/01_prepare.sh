#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"
parseArgs
importTestFunctions

prepareWorkdir
prepareBaseInfra

PrepareGatewayInfra
prepareTestcase
