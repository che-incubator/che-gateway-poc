#!/bin/sh

function prepareTestStructure() {
  mkdir -p ${REPORT_DIR}
  JMETER_TEST_FILE=${WORKDIR}/test.jmx
  cp "${TESTCASES_DIR}/tc_${TESTCASE}/test.jmx" ${JMETER_TEST_FILE}
  cp "${TESTCASES_DIR}/tc_${TESTCASE}/test.jmx" ${REPORT_DIR}/test.xml
}
