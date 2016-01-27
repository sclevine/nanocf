#!/bin/bash

set -ex

apt-get -qqy install git

git -C nanocf submodule update --init test/src/github.com/cloudfoundry/cf-acceptance-tests
ln -sf $PWD/nanocf/test /test

nanocf local.nanocf
nanocf-test local.nanocf
