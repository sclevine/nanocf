# NanoCF

[NanoCF](https://hub.docker.com/r/sclevine/nanocf/) is a full Cloud Foundry
installation in a single Docker container. It is currently based on
[Cloud Foundry Release v228](https://github.com/cloudfoundry/cf-release/tree/v228)
and it passes the
[Cloud Foundry Acceptance Tests](https://github.com/cloudfoundry/cf-acceptance-tests).

It is compatible with both [Docker](https://www.docker.com) and
[Garden Linux](https://github.com/cloudfoundry-incubator/garden-linux/).

NanoCF is a usable [Concourse CI](http://concourse.ci) base image for
privileged tasks.

## Setup

You must be able to run docker images in privileged mode to build or run NanoCF.

Building NanoCF requires the BOSH CLI gem. Therefore, you must have Ruby
installed to build NanoCF.

Concourse workers running NanoCF should have high I/O throughput as well as
enough system memory to store all pushed application containers.

### Mac OS X
To setup Docker Machine for building and running NanoCF on Mac OS X:
```bash
  $ brew install docker-machine
  $ cd nanocf
  $ eval "$(./bin/setup-osx virtualbox)"
  $ # OR
  $ eval "$(./bin/setup-osx vmware)"
```

## Running in Docker

To run NanoCF in Docker:
```bash
  $ docker run -m 3g --privileged sclevine/nanocf
```
This will boot NanoCF configured with \<container-ip\>.xip.io as the CF system
domain. It may be targetted from outside of the container, but note that xip.io
often has a high failure rate.

Running NanoCF interactively will cause the container to spawn a shell after CF
finishes booting:
```bash
  $ docker run -it -m 3g --privileged sclevine/nanocf
  ...
  > $ cf push my-app ...
```
The `cf` CLI is installed in the container and pre-targetted at NanoCF.
Inside of the container the CF system domain is resolved using dnsmasq, so
using the NanoCF shell to push apps is not affected by xip.io flakiness.
This is the recommended way of using NanoCF with
[Docker Machine](https://docs.docker.com/machine/), as a NanoCF container in
a machine is only addressable from within the machine VM.

To push local apps from inside of the container, consider using a volume mount:
```bash
  $ docker run -it -m 3g --privileged -v $PWD:/apps sclevine/nanocf
  > $ cd /app/myapp
  > $ cf push myapp ...
```

A custom domain may be provided as an argument to `docker run`:
```bash
  $ docker run -m 3g --privileged sclevine/nanocf example.com
```
The provided domain will always resolve to the container IP from inside of the
NanoCF container. However, for the `cf` utility (and any application routes)
to be functional outside of the container, one of the following must be true:

1. The provided domain must have a wildcard CNAME record that resolves to the
   container IP (\*.example.com).
2. The host system running the container must add the container IP to its DNS
   servers (in `/etc/resolv.conf`, for example).

For convenience, \*.nanocf.sclevine.org resolves to the first container IP
address (172.17.0.2) assigned by Docker Machine.

If you are running NanoCF in Docker Machine, it may be difficult to use
the `cf` utility or application routes from your host system.
Using `docker run -P` with a system domain that resolves to the Docker Machine
VM IP may fix this issue.

## Running in Concourse

NanoCF may be used as a Concourse base image for privileged tasks.
The `nanocf` script in `$PATH` must be called to start CF.

Example pipeline configuration:
```yaml
  resources:
    - name: myapp
      type: git
      source:
        uri: https://example.com/myapp.git
        branch: master

  jobs:
    - name: push-myapp
      plan:
      - get: myapp
      - task: push
        privileged: true
        file: myapp/task.yml
```

Example task configuration file (`myapp/task.yml`):
```yaml
  ---
  platform: linux
  image: docker:///sclevine/nanocf
  inputs:
  - name: myapp
  run:
    path: myapp/push.sh
```

Example run script (`myapp/push.sh`):
```bash

#!/bin/bash
nanocf local.nanocf
cd myapp
cf push myapp

curl -v "http://myapp.local.nanocf"
```

To run CATs against a NanoCF task deployed to Concourse, make the repository's
`test` directory available at `/test` in the NanoCF container, and run the
`nanocf-test` command. NanoCF must be booted with the `nanocf` command first.

## Development

To build NanoCF:
```bash
  $ git clone --recursive https://github.com/sclevine/nanocf
  $ cd nanocf
  $ bundle install
  $ eval "$(./bin/setup-osx virtualbox)" # or vmware
  $ ./bin/build
```
To run CATs against an sclevine/nanocf image:
```bash
  $ ./bin/test
```

