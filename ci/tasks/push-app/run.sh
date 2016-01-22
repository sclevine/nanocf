#!/bin/bash

set -ex

/var/micropcf/concourse

cf push app -o cloudfoundry/lattice-app -m 32M
curl -v "http://app.local.nanocf.io"
