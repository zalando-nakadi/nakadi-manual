[![Build Status](https://travis-ci.org/zalando/nakadi-manual.svg?branch=master)](https://travis-ci.org/zalando/nakadi-manual)

----
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [About](#about)
- [Local Setup](#local-setup)
  - [Installation](#installation)
  - [Running a Local Gitbook](#running-a-local-gitbook)
  - [Running a Build](#running-a-build)
- [Publishing the docs](#publishing-the-docs)
  - [Travis CI  Publishing](#travis-ci--publishing)
  - [Manual Publishing](#manual-publishing)
- [The API Reference Section](#the-api-reference-section)
  - [Generating the Section](#generating-the-section)
  - [Picking up Changes](#picking-up-changes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->
----

### About

This is a documentation project for [Nakadi](https://github.com/zalando/nakadi). It's based on [Gitbook](https://www.gitbook.com) and publishes content to Github Pages.

Gitbook/Github pages want to use README.md as part of the book, so the howto is here.

### Local Setup

#### Installation

You'll need to install npm and java 8 to get going. Once you've got those, clone the project, `cd` to the project's home directory and run:

```
npm install gitbook-cli --save-dev
npm run docs:prepare
```

This will set up gitbook and gitbook-cli locally in the project.

#### Running a Local Gitbook

You can start a local server on [http://localhost:4000](http://localhost:4000) that will watch for changes:

```
npm run docs:watch
```


#### Running a Build

If you just want to run a build you can run: 

```
npm run docs:build
```

This will update the pages content in the `_book` directory.

### Publishing the docs

#### Travis CI  Publishing

Docs are published to github pages using Travis CI. 

Travis has an envar called `GH_PAGES_TOKEN` set with a personal access token that allows it to push to the `gh-pages` branch. The token is also encrypted in `.travis.yml` files `env.global` area using the travis cli command:

```sh
gem install travis
travis encrypt -r zalando/nakadi-manual GH_PAGES_TOKEN=${GH_PAGES_TOKEN} --add
```

The build step requires both NPM and JDK 8 - to allow Travis to use both and set JDK 8 via its `jdk_switcher` command, the setup uses the `trusty` Ubuntu distribution (otherwise the build will fail as JDK8 is not the default in Travis).

The publishing script run by Travis is `gh_pages_publish.sh`. The script restricts publishing to updates against the master branch - pull requests and other branches will only result in a build.


#### Manual Publishing

You can force a manual publish:

```sh
npm run docs:publish
```

For this to work it will need a `GH_PAGES_TOKEN` envar set with a [personal access token](https://github.com/settings/tokens/new).

### The API Reference Section

#### Generating the Section

This section is generated from a copy of the Open API definition. The definition files are kept in `./docs/api-spec-oai` and the publishing code targets the symlinked file `nakadi-oai-current.yaml`. Eventually it's hoped the build will run directly from the Nakadi project's yaml file, but for now there's a managed copy locally.

Generation uses the [swagger2markup](http://swagger2markup.github.io/swagger2markup/1.0.1-SNAPSHOT) project to convert the yaml to markdown and place the output into the `api-spec-generated` directory. The swagger2markup configuration is in the `./bin` directory and the additional reference text is in the `api-spec-extensions` directory. The swagger2markup jar files are checked in source to make it easy to run a build.

#### Picking up Changes

The `npm run docs:watch` will not automatically pick up changes to the Open API files. To have the changes seen, run:

```sh
npm run docs:genapi
```


