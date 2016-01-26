#!/bin/bash

set -ex

nanocf local.nanocf

apt-get -qqy install git

git -C nanocf submodule update --init micropcf
git -C nanocf/micropcf submodule update --init test/src/github.com/cloudfoundry/cf-acceptance-tests
git -C nanocf/micropcf submodule update --init test/src/github.com/cloudfoundry-incubator/diego-acceptance-tests
git -C nanocf/micropcf submodule update --init --recursive images/releases/diego-release

./nanocf/micropcf/bin/cats local.nanocf
./nanocf/micropcf/bin/dats local.nanocf
