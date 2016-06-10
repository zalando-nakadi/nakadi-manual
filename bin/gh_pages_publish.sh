#!/bin/bash
set -o errexit -o nounset

echo "Running Github Pages Publish from `pwd`"

SOURCE_BRANCH="master"
TARGET_BRANCH="gh-pages"

echo "Deploy attempt from $TRAVIS_BRANCH"

if [ "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Publish not allowed on a non-master branch, $TRAVIS_BRANCH, running build instead"
    npm run docs:build
    exit 0
fi

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "Publish not allowed from a pr, running build instead"
    npm run docs:build
    exit 0
fi


GITREV=$(git rev-parse --short HEAD)
git config user.name "Travis CI"
git config user.email "travis@travis-ci.org";

echo "Publishing new pages from branch $TRAVIS_BRANCH rev ${GITREV}"

npm run docs:build 
cd _book
git init
git commit --allow-empty -m "Update GitHub Pages: ${GITREV}"
git checkout -b gh-pages
git add -A .
git commit -am "Update GitHub Pages: ${GITREV}"

# -q to stop the token being printed
git push -q -f https://$GH_PAGES_TOKEN@github.com/zalando/nakadi-manual


