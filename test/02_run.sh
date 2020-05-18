#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"

function run() {
  # prepare report directory
  REPORT_DIR="${REPORTS_DIR}/${GATEWAY}_tc${TESTCASE}_$( date +%s )"
  mkdir -p ${REPORT_DIR}
  cp ${JMETER_TEST_FILE} ${REPORT_DIR}/test.xml
  echo "${@}" >> ${REPORT_DIR}/params.txt

  docker run --rm \
  -v ${REPORT_DIR}:${REPORT_DIR}:Z \
  -v ${WORKDIR}:${WORKDIR}:Z \
  --add-host ${HOST}:${HOST_IP} \
  justb4/jmeter:5.1.1 \
  -n -Jjmeter.reportgenerator.overall_granularity=1000 -e \
  -t ${JMETER_TEST_FILE} -l ${REPORT_DIR}/test.log -j ${REPORT_DIR}/jmeter.log -o ${REPORT_DIR}/dashboard "${@}"

  cat ${REPORT_DIR}/dashboard/statistics.json
  echo "${GATEWAY},${TESTCASE},${DURATION},${LOOP_DELAY},${REQUEST_THREADS},${WORKSPACES_CREATE},${WORKSPACE_DELAY},${WORKSPACE_INITIAL_DELAY},$( cat ${REPORT_DIR}/dashboard/statistics.json | jq -r '.Total | [.sampleCount, .errorCount, .errorPct, .meanResTime, .minResTime, .maxResTime, .pct1ResTime, .pct2ResTime, .pct3ResTime, .throughput, .receivedKBytesPerSec, .sentKBytesPerSec] | join(",")' )" >> ${TEST_STATS_FILE}
}


if [ ! -f ${TEST_STATS_FILE} ]; then
  echo "gateway,testcase,duration,loop_delay,request_threads,workspaces_create,workspace_delay,workspace_initial_delay,sampleCount,errorCount,errorPct,meanResTime,minResTime,maxResTime,pct90ResTime,pct95ResTime,pct99ResTime,throughput,receivedKBytesPerSec,sentKBytesPerSec" > ${TEST_STATS_FILE}
fi
# if there is params.csv in the testcase, read this file and run in the loop
# otherwise run once with default parameters from 'test.jmx' file
if [ -f ${TEST_PARAMS_FILE} ]; then
  sed 1d ${TEST_PARAMS_FILE} | while IFS=, read -r DURATION LOOP_DELAY REQUEST_THREADS WORKSPACES_CREATE WORKSPACE_DELAY WORKSPACE_INITIAL_DELAY; do
    run "-Jduration=${DURATION}" \
    "-Jloop_delay=${LOOP_DELAY}" \
    "-Jrequest_threads=${REQUEST_THREADS}" \
    "-Jworkspaces_create=${WORKSPACES_CREATE}" \
    "-Jworkspace_delay=${WORKSPACE_DELAY}" \
    "-Jworkspace_initial_delay=${WORKSPACE_INITIAL_DELAY}" \
    "-Jjmeter.reportgenerator.report_title=loop_delay=${LOOP_DELAY};request_threads=${REQUEST_THREADS};workspaces_create=${WORKSPACES_CREATE};workspace_delay=${WORKSPACE_DELAY};workspace_initial_delay=${WORKSPACE_INITIAL_DELAY}"
  done
else
  run
fi
