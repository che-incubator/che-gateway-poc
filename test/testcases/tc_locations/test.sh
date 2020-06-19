#!/bin/bash

while IFS=, read -r NAME TEST_HOST URL_PATH; do
    if [ ${NAME} == "name" ]; then
        continue
    fi

    URL="${URL_PATH}/"
    if [ -z "${URL_PATH}" ]; then
        URL="/"
    fi

    LOC=`curl -v http://${TEST_HOST}${URL}cookie 2>&1 | grep -i '< Location:' | cut -d' ' -f3`

    if [ ! -z "${LOC##*$URL*}" ]; then
        echo "ERROR: ${NAME}"
    fi
done < ${WORKDIR}/urls.csv
