#!/usr/bin/env bash
npm run docs:index
npm run docs:genapi
npm run docs:prepare
rm -rf _book
mv ./.gitignore ./.gitignore-orig
cp ./gh_pages_gitignore ./.gitignore
gitbook build -log=debug --debug
mv ./.gitignore-orig ./.gitignore
rm -rf _book/bin
