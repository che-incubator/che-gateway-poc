#!/bin/sh

set -e

echo ${PWD}

sleep 30
for I in {1..25}; do
  sh -x addPreparedWorkspace.sh
  sleep 10
done
