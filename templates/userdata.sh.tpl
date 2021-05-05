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
  enable_wireguard_service
}

main
