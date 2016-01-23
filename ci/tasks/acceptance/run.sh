#!/bin/bash

set -ex

nanocf local.nanocf

# Remove this after image includes golang
curl -L https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz | tar -C /usr/local -xz
( cd /usr/local/bin && ln -s ../go/bin/* . )

apt-get -qqy install git

git -C nanocf submodule update --init micropcf
git -C nanocf/micropcf submodule update --init test/src/github.com/cloudfoundry/cf-acceptance-tests
git -C nanocf/micropcf submodule update --init test/src/github.com/cloudfoundry-incubator/diego-acceptance-tests
git -C nanocf/micropcf submodule update --init --recursive images/releases/diego-release

./nanocf/micropcf/bin/cats
./nanocf/micropcf/bin/dats
