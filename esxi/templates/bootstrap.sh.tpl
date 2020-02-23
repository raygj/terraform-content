#!/bin/bash

sudo snap remove docker
apt-get update
apt-get install -y unzip dnsmasq nano net-tools nmap socat

# minikube installation
# https://github.com/raygj/vault-content/tree/master/use-cases/vault-agent-kubernetes#install-minikube

cd /usr/local/bin
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_1.4.0.deb \
&& sudo dpkg -i minikube_1.4.0.deb

egrep -q 'vmx|svm' /proc/cpuinfo && echo yes || echo no

sudo minikube config set vm-driver none

sudo minikube start

# install kubectl

cd /usr/local/bin

sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/` \
curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

sudo chmod +x ./kubectl

# install helm

cd /temp

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3

sudo chmod 700 get_helm.sh

sudo ./get_helm.sh