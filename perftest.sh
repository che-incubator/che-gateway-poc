#!/bin/sh

set -e

JMETER_BIN=jmeter-cli
REPORT_DIR=perfReport_$( date +%s )

mkdir ${REPORT_DIR}

${JMETER_BIN} -n -t perftest.jmx -l ${REPORT_DIR}/perftest.log -e  -o ${REPORT_DIR}/perftest_report
