#!/bin/bash

while IFS=, read -r NAME TEST_HOST URL_PATH; do
    if [ ${NAME} == "name" ]; then
        continue
    fi

    URL="${URL_PATH}/"
    if [ -z "${URL_PATH}" ]; then
        URL="/"
    fi

    LOC=`curl -v http://${TEST_HOST}${URL}cookie/ 2>&1 | grep -i -E "< Set-Cookie: test-with-path=\"[^\"]+\"; Path=${URL}cookie/"`

    if [ -z "${LOC}" ]; then
        echo "ERROR: ${NAME}"
    fi
done < ${WORKDIR}/urls.csv
