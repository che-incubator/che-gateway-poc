#!/bin/sh

set -e

. "$( dirname "${0}" )/env.sh"

function run() {
  # prepare report directory
  REPORT_DIR="${REPORTS_DIR}/${GATEWAY}_tc${TESTCASE}_$( date +%s )"
  mkdir -p ${REPORT_DIR}
  cp ${JMETER_TEST_FILE} ${REPORT_DIR}/test.xml
  echo "${@}" >> ${REPORT_DIR}/params.txt

  # run testcase's actions
  if [ -f ${TESTCASE_DIR}/actions.sh ]; then
    sh -x ${TESTCASE_DIR}/actions.sh > ${REPORT_DIR}/actions.log 2>&1 &
    ADD_WORKSPACES_PID=$!
  fi

  docker run --rm \
  -v ${REPORT_DIR}:${REPORT_DIR}:Z \
  -v ${BASE_DIR}:${BASE_DIR}:Z \
  -e USER=${USER} \
  --add-host ${HOST}:${HOST_IP} \
  docker.io/justb4/jmeter:5.1.1 \
  -n -Jjmeter.reportgenerator.overall_granularity=1000 -e \
  -t ${JMETER_TEST_FILE} -l ${REPORT_DIR}/test.log -j ${REPORT_DIR}/jmeter.log -o ${REPORT_DIR}/dashboard "${@}"

  if [ ! -z ${ADD_WORKSPACES_PID} ] && kill -0 ${ADD_WORKSPACES_PID} ; then
    kill ${ADD_WORKSPACES_PID}
  fi

  cat ${REPORT_DIR}/dashboard/statistics.json
  if [ -f ${TEST_PARAMS_FILE} ]; then
    echo "${GATEWAY},${TESTCASE},$( IFS=","; echo "${LINE[*]}" ),$( cat ${REPORT_DIR}/dashboard/statistics.json | jq -r '.Total | [.sampleCount, .errorCount, .errorPct, .meanResTime, .minResTime, .maxResTime, .pct1ResTime, .pct2ResTime, .pct3ResTime, .throughput, .receivedKBytesPerSec, .sentKBytesPerSec] | map_values(tostring) | join(",")' )" >> ${TEST_STATS_FILE}
  fi
}

# if there is params.csv in the testcase, read this file and run in the loop
# otherwise run once with default parameters from 'test.jmx' file
if [ -f ${TEST_PARAMS_FILE} ]; then
  echo "gateway,testcase,$( head -n 1 ${TEST_PARAMS_FILE} ),sampleCount,errorCount,errorPct,meanResTime,minResTime,maxResTime,pct90ResTime,pct95ResTime,pct99ResTime,throughput,receivedKBytesPerSec,sentKBytesPerSec" > ${TEST_STATS_FILE}
  # read 1st line of csv to have parameter names
  IFS=',' read -r -a PARAMS <<< "$( head -n 1 ${TEST_PARAMS_FILE} )"

  # read rest of file line by line
  sed 1d ${TEST_PARAMS_FILE} | while read -r LINE; do
    if [ -z ${LINE} ]; then continue; fi
    JMETER_ARGS=""
    JMETER_REPORT_TITLE=""
    # split line by ','
    IFS=',' read -r -a LINE <<< "${LINE}"
    # and join all params with names to jmeter parameter and report title
    for i in "${!LINE[@]}"; do
      JMETER_ARGS="${JMETER_ARGS} -J${PARAMS[i]}=${LINE[i]}"
      JMETER_REPORT_TITLE="${JMETER_REPORT_TITLE};${PARAMS[i]}=${LINE[i]}"
    done
    # join report title to rest of the args
    JMETER_ARGS="${JMETER_ARGS} -Jjmeter.reportgenerator.report_title=${JMETER_REPORT_TITLE}"

    # and run
    run "${JMETER_ARGS}"
  done
else
  run
fi
