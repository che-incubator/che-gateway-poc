#!/bin/sh

PROCESSES=$( oc exec che-gateway-6d66955666-wmxkx -c controller -- "ps" "-o" "pid,ppid,comm" | grep haproxy )

readarray -t PROCESSES <<<"$PROCESSES"
PATTERN='\s+[0-9]+\s+0\s+haproxy'
for P in "${PROCESSES[@]}"; do
  if [[ $P =~ ${PATTERN} ]] ; then
    echo "$P OK"
    PID=$( echo ${P} | awk '{print $1;}' )
    oc exec che-gateway-6d66955666-wmxkx -c controller -- "kill" "-HUP" "${PID}"
  else
    echo "$P not OK"
  fi
done
