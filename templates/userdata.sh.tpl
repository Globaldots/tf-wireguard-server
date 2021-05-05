#!/usr/bin/env bash

set -xeu

# Install Wireguard and tools
function install_packages() {
  apt update -y && apt install -y \
    wireguard \
    wireguard-tools \
    resolvconf \
    awscli \
    jq \
    ;
}

# Enable IPv4/6 forwarding
function tune_kernel_parameters() {
  sed -i '/#net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf
  sed -i '/#net.ipv6.conf.all.forwarding=1/s/^#//g' /etc/sysctl.conf
  sed -i '/#net.ipv4.conf.all.proxy_arp=1/s/^#//g' /etc/sysctl.conf

  sysctl -p

tee /etc/security/limits.conf << EOF
* hard nofile 64000
* soft nofile 64000
root hard nofile 64000
root soft nofile 64000
EOF
}

# Get configuration file from S3
function get_config_from_s3() {
   aws s3 cp s3://${s3_bucket_name}/wg0.conf  /etc/wireguard/ --region ${region}
}

# Enable Wireguard
function enable_wireguard_service() {
  wg-quick up wg0
  wg show
  systemctl enable wg-quick@wg0
}

# Cleanup userdata script
function clean_up() {
  # remove this script
  rm -f "$0"
}

trap clean_up SIGINT SIGTERM EXIT

# Main
function main() {
  install_packages
  tune_kernel_parameters
  get_config_from_s3
  enable_wireguard_service
}

main
