#!/bin/env bash

set -x

docker network create footloose-cluster

docker pull korvus/debian10:0.6.3

footloose -c footloose-calico.yaml create

footloose -c footloose-calico.yaml ssh root@node0 -- "env INSTALL_K3S_SKIP_DOWNLOAD=true /root/install-k3s.sh --flannel-backend=none --cluster-cidr=192.168.0.0/16 --disable=traefik"
export k3stoken=$(footloose -c footloose-calico.yaml ssh root@node0 -- cat /var/lib/rancher/k3s/server/node-token)
footloose -c footloose-calico.yaml ssh root@node1 -- "env INSTALL_K3S_SKIP_DOWNLOAD=true env K3S_URL=https://node0:6443 env K3S_TOKEN=$k3stoken /root/install-k3s.sh"
footloose -c footloose-calico.yaml ssh root@node2 -- "env INSTALL_K3S_SKIP_DOWNLOAD=true env K3S_URL=https://node0:6443 env K3S_TOKEN=$k3stoken /root/install-k3s.sh"


