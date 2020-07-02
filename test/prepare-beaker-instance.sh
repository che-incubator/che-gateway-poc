#!/bin/sh

BEAKER_HOST="${BEAKER_HOST:-$1}"

if [ -z "$BEAKER_HOST" ]; then
    echo "\$BEAKER_HOST env var required or a parameter to this script"
fi

function beak() {
    ssh root@$BEAKER_HOST $@
}

beak mkdir perf-test
scp -r ../* root@$BEAKER_HOST/root/perf-test

beak dnf install -y origin-clients jq mc podman podman-docker

