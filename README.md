# NanoCF: Cloud Foundry in a single Docker container

## Setup

You must be able to run docker images in privileged mode to run NanoCF.

To setup docker-machine for building and running NanoCF on Mac OS X with VMWare Fusion:
```bash
  $ cd nanocf
  $ eval "$(./setup-osx-vmware)"
```

## Running

To run NanoCF:
```bash
  $ docker run -m 3g --privileged sclevine/nanocf
```
This will make <container-ip>.xip.io the CF system domain.

To run NanoCF with a custom domain:
```bash
  $ docker run -m 3g --privileged sclevine/nanocf <custom-domain>
```
To avoid xip.io flakiness, \*.nanocf.sclevine.org resolves to the first
container IP address assigned by docker-machine (172.17.0.2).

If you're running NanoCF with docker-machine, the container will only
be addressable from the docker-machine VM. Consider mounting your local
workspace in the VM and using the `cf` utility installed in the container:
```bash
  $ docker run -m 3g --privileged -v /mnt/hgfs/$PWD:/workspace sclevine/nanocf nanocf.sclevine.org
  $ docker exec <container-ip> bash
  > $ cf push ...
```

Alternatively, NanoCF can be bound to ports 80, 443, and 2222 on its containing docker-machine:
```bash
  $ docker run -m 3g --privileged -P sclevine/nanocf <docker-machine-ip>.xip.io
```
This will allow you to push apps directly from your host system.

## Building

To build MicroPCF:
```bash
  $ git clone --recursive https://github.com/sclevine/nanocf
  $ cd nanocf
  $ eval "$(./setup-osx-vmware)"
  $ ./build
```
