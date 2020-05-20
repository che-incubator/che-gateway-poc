#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"
echo "adding prepared workspace at '$( date )'"
writeTestAndFlushPreparedWorkspaces 1
echo "finished adding prepared workspace at '$( date )'"

#printWorkspaces
