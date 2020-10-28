#!/bin/env bash

set -x

docker network create footloose-cluster

docker pull korvus/debian10

footloose -c footloose-flannel.yaml create

footloose ssh root@node0 -- "env INSTALL_K3S_SKIP_DOWNLOAD=true /root/install-k3s.sh"
env k3stoken=$(footloose ssh root@node0 -- cat /var/lib/rancher/k3s/server/node-token)
footloose ssh root@node1 -- "env INSTALL_K3S_SKIP_DOWNLOAD=true env K3S_URL=https://node0:6443 env K3S_TOKEN=$k3stoken /root/install-k3s.sh"
footloose ssh root@node2 -- "env INSTALL_K3S_SKIP_DOWNLOAD=true env K3S_URL=https://node0:6443 env K3S_TOKEN=$k3stoken /root/install-k3s.sh"


