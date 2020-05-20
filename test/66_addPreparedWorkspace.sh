#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"

writeTestAndFlushPreparedWorkspaces 1

printWorkspaces
