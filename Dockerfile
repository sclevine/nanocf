FROM ubuntu:14.04.3

ENV HOME /root
ENV CF_VERSION 6.14.1
ENV RTR_VERSION 2.3.0

EXPOSE 80 443 2222
VOLUME ["/var/vcap/data/garden/aufs_graph"]
CMD ["/var/micropcf/provision"]

RUN \
  apt-get -qqy install software-properties-common && \
  add-apt-repository -y ppa:brightbox/ruby-ng && \
  apt-get -qqy update && \
  apt-get -qqy --force-yes dist-upgrade && \
  apt-get -qqy update && \
  apt-get -qqy install wget curl unzip zip jq \
    libruby2.1 ruby2.1 aufs-tools iptables

RUN \
  curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_VERSION}&source=github-rel" | tar -C /usr/local/bin -xz && \
  curl -L "https://github.com/cloudfoundry-incubator/routing-api-cli/releases/download/${RTR_VERSION}/rtr-linux-amd64.tgz" | tar -C /usr/local/bin -xz

ADD assets /opt/bosh-provisioner/assets
ADD config.json /opt/bosh-provisioner/
ADD provision /var/micropcf/

ADD micropcf/images/manifest.yml /tmp/
ADD micropcf/images/scripts/* /var/micropcf/
