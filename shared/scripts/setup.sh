#!/usr/bin/env bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1


#set -e

# Disable interactive apt-get prompts
export DEBIAN_FRONTEND=noninteractive

cd /ops

CONFIGDIR=/ops/shared/config
sudo apt-get install -yq  apt-utils

# Install HashiCorp products
CONSULVERSION=1.20.1
VAULTVERSION=1.18.3
NOMADVERSION=1.9.4
CONSULTEMPLATEVERSION=0.39.1

sudo apt-get update && sudo apt-get install gpg
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -yq \
                    consul="${CONSULVERSION}*" \
                    vault="${VAULTVERSION}*" \
                    nomad="${NOMADVERSION}*" \
                    consul-template="${CONSULTEMPLATEVERSION}*"

# Dependencies
sudo apt-get install -yq software-properties-common
sudo apt-get install -yq dmidecode
sudo apt-get update
sudo apt-get install -yq unzip tree jq curl

# Disable the firewall
sudo ufw disable || echo "ufw not installed"

# Docker
distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
sudo apt-get install -yq apt-transport-https ca-certificates gnupg2
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to apt-get sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# Java
curl -O https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb
sudo apt-get install -yq ./jdk-21_linux-x64_bin.deb