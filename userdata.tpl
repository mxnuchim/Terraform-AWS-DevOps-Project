#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \ 
apt-transport-https \ 
ca-certificates \ 
curl \
gnupg-agent \
software-properties-common &&
curl -f5SL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch-amd64] https://download.docker.com/linux/ubuntu $(Isb release -cs) stable" &&
sudo apt-get update -y &&
sudo sudo apt-get install docker-ce docker-ce-cli containerd.io -y && 
sudo usermod -aG docker ubuntu