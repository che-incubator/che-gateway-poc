#!/bin/sh

if [ -z "$USER" ]; then
    echo "\$USER env var required."
    exit 1
fi

if [ -z "$TOKEN" ]; then
    echo "\$TOKEN env var required."
    exit 1
fi

CLUSTER="${CLUSTER:-https://api.che-dev.x6e0.p1.openshiftapps.com:6443}"

GATEWAY=$1
shift
#TESTCASES=`find testcases -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | cut -d'_' -f 2 | sort`
TESTCASES="${@:-0 0-ws 1 1-ws 2 2-ws 3 3-ws 4 4-ws 5 5-ws cookies locations}"

for t in $TESTCASES; do
    oc login --token=$TOKEN --server=$CLUSTER
    ./01_prepare.sh $GATEWAY $t
    sleep 70
    oc login --token=$TOKEN --server=$CLUSTER
    ./02_run.sh $GATEWAY $t
    oc login --token=$TOKEN --server=$CLUSTER
    echo y | ./99_cleanup.sh $GATEWAY $t
done
