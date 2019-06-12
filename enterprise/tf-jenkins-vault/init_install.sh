#!/bin/bash
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88 | grep docker@docker.com || exit 1
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce

sudo groupadd docker
sudo usermod -aG docker ubuntu
sudo systemctl restart docker


sudo docker run -d -p 8080:8080 -p 50000:50000  andrefcpimentel/jenkins-vault:latest
