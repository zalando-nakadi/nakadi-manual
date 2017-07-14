#!/usr/bin/env bash
npm install


#HACK: ignore error go to directory and fix it there
#https://github.com/GitbookIO/gitbook/issues/1818
set -e
gitbook fetch 3.2.2
set +e
cd ~/.gitbook/versions/3.2.2
npm install
cd -
