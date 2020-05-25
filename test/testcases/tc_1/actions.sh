#!/bin/sh

set -e

echo ${PWD}

sleep 30
for I in {1..5}; do
  sh -x 66_addPreparedWorkspace.sh
  sleep 10
done
