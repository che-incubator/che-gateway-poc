#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"
echo "$( date +%s%N ): adding prepared workspace"
writeTestAndFlushPreparedWorkspaces 1
echo "$( date +%s%N ): finished adding prepared workspace"

#printWorkspaces
