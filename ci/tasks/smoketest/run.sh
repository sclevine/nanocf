#!/bin/bash

set -ex

nanocf local.nanocf

cd app
cf push test-app
curl -v "http://test-app.local.nanocf"
