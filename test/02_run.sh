#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"

prepareTestStructure

HOST_IP="$( getent hosts ${HOST} | awk '{ print $1 }' )"
docker run --rm \
-v ${REPORT_DIR}:${REPORT_DIR}:Z \
-v ${WORKDIR}:${WORKDIR}:Z \
--add-host ${HOST}:${HOST_IP} \
justb4/jmeter:5.1.1 \
-n -t ${JMETER_TEST_FILE} -l ${REPORT_DIR}/test.log -j ${REPORT_DIR}/jmeter.log -e -o ${REPORT_DIR}/dashboard
