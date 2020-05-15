#!/bin/sh

set -e

set -x
. "$( dirname "${0}" )/env.sh"

JMETER_BIN=jmeter-cli

prepareTestStructure
${JMETER_BIN} -n -t ${JMETER_TEST_FILE} -l ${REPORT_DIR}/test.log -j ${REPORT_DIR}/jmeter.log -e  -o ${REPORT_DIR}/dashboard
