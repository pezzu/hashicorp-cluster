#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

CLOUD_ENV=${cloud_env}
RETRY_JOIN="${retry_join}"

CONFIGDIR=/ops/shared/config
CONSULCONFIGDIR=/etc/consul.d
NOMADCONFIGDIR=/etc/nomad.d
CONSULTEMPLATECONFIGDIR=/etc/consul-template.d
HOME_DIR=ubuntu

# Wait for network
sleep 15


# Get IP from metadata service
case $CLOUD_ENV in
  aws)
    TOKEN=$(curl -X PUT "http://instance-data/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    IP_ADDRESS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://instance-data/latest/meta-data/local-ipv4)
    ;;

  gce)
    IP_ADDRESS=$(curl -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip)
    ;;

  azure)
    IP_ADDRESS=$(curl -s -H Metadata:true --noproxy "*" http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0?api-version=2021-12-13 | jq -r '.["privateIpAddress"]')
    ;;

  *)
    exit "ERROR: CLOUD_ENV not set to one of aws, gce, or azure - exiting."
    ;;
esac

# Systemd-resolved config to enable .consul domain lookups using the local Consul agent
# https://developer.hashicorp.com/consul/tutorials/networking/dns-forwarding#systemd-resolved-setup
mkdir -p /etc/systemd/resolved.conf.d/
cat <<EOT > /etc/systemd/resolved.conf.d/consul.conf
[Resolve]
DNS=127.0.0.1:8600
DNSSEC=false
Domains=~consul
EOT

systemctl restart systemd-resolved.service

# Configure bridge network to route traffic through iptables
sudo modprobe br_netfilter
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

# Consul
sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/consul_client.hcl
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $CONFIGDIR/consul_client.hcl
sudo cp $CONFIGDIR/consul_client.hcl $CONSULCONFIGDIR/consul.hcl

sudo systemctl enable consul.service --now
sleep 10

# Nomad
## Install CNI binaries
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz && \
  sudo mkdir -p /opt/cni/bin && \
  sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

sed -i "s/IP_ADDRESS/$IP_ADDRESS/g" $CONFIGDIR/nomad_client.hcl
sed -i "s/RETRY_JOIN/$RETRY_JOIN/g" $CONFIGDIR/nomad_client.hcl
sudo cp $CONFIGDIR/nomad_client.hcl $NOMADCONFIGDIR/nomad.hcl
sudo systemctl enable nomad.service --now
sleep 10

export NOMAD_ADDR=http://$IP_ADDRESS:4646

# Consul Template
sudo cp $CONFIGDIR/consul-template.hcl $CONSULTEMPLATECONFIGDIR/consul-template.hcl
sudo cp $CONFIGDIR/consul-template.service /etc/systemd/system/consul-template.service

# Add hostname to /etc/hosts
echo "127.0.0.1 $(hostname)" | sudo tee --append /etc/hosts

# Add Docker bridge network IP to /etc/resolv.conf (at the top)
DOCKER_BRIDGE_IP_ADDRESS=(`ifconfig docker0 2>/dev/null|awk '/inet addr:/ {print $2}'|sed 's/addr://'`)
echo "nameserver $DOCKER_BRIDGE_IP_ADDRESS" | sudo tee /etc/resolv.conf.new
cat /etc/resolv.conf | sudo tee --append /etc/resolv.conf.new
sudo mv /etc/resolv.conf.new /etc/resolv.conf

# Set env vars for tool CLIs
echo "export VAULT_ADDR=http://$IP_ADDRESS:8200" | sudo tee --append /home/$HOME_DIR/.bashrc
echo "export NOMAD_ADDR=http://$IP_ADDRESS:4646" | sudo tee --append /home/$HOME_DIR/.bashrc
