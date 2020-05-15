#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"

# prepare report directory
mkdir -p ${REPORT_DIR}
cp "${TESTCASES_DIR}/tc_${TESTCASE}/test.jmx" ${REPORT_DIR}/test.xml

HOST_IP="$( getent hosts ${HOST} | awk '{ print $1 }' )"
docker run --rm \
-v ${REPORT_DIR}:${REPORT_DIR}:Z \
-v ${WORKDIR}:${WORKDIR}:Z \
--add-host ${HOST}:${HOST_IP} \
justb4/jmeter:5.1.1 \
-n -Jjmeter.reportgenerator.overall_granularity=1000 -e \
-t ${JMETER_TEST_FILE} -l ${REPORT_DIR}/test.log -j ${REPORT_DIR}/jmeter.log -o ${REPORT_DIR}/dashboard
