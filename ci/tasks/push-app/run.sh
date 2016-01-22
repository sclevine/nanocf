#!/bin/bash

set -ex

nanocf local.nanocf.io

cd app
cf push some-app

curl -v "http://some-app.local.nanocf.io"
