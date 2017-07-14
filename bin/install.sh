#!/usr/bin/env bash

DIR="${HOME}/.gitbook/versions/3.2.2"
if [ -d "${DIR}" ]; then
    echo "Found ${DIR}"
    exit 0;
fi

#HACK: ignore error go to directory and fix it there
#https://github.com/GitbookIO/gitbook/issues/1818

echo "Not found ${DIR}. Installing";
set -e
gitbook fetch 3.2.2
set +e
cd ${DIR}
npm install
cd -
