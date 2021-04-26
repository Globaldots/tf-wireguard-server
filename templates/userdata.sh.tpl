#!/usr/bin/env bash

set -xeu

function install_packages() {
  sudo apt update -y
  sudo apt install -y \
    wireguard \
    wireguard-tools \
    resolvconf \
    awscli \
    jq \
    ;
}

function tune_kernel_parameters() {
  # enable forwarding
  sudo sed -i '/#net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf
  sudo sed -i '/#net.ipv6.conf.all.forwarding=1/s/^#//g' /etc/sysctl.conf
  sudo sysctl -p
}

function get_private_key_from_ssm_parameter_store() {
   aws ssm get-parameter \
    --region ${region} \
    --name ${ssm_parameter} \
    --with-decryption \
    --output json | \
   jq -r '.Parameter.Value' | \
   sudo tee /etc/wireguard/wg0.conf &> /dev/null
}

function enable_wireguard_service() {
  sudo modprobe wireguard
  sudo wg-quick up wg0
  sudo wg show
  sudo systemctl enable wg-quick@wg0
}

function main() {
  install_packages
  tune_kernel_parameters
  get_private_key_from_ssm_parameter_store
  enable_wireguard_service
}

main
