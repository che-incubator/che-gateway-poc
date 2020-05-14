#!/bin/sh

. "$( dirname "${0}" )/env.sh"
parseArgs
importTestFunctions

set -x

FullGatewayReconfig
