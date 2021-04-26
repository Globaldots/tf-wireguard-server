#!/usr/bin/env bash

set -xeu

function install_packages() {
  apt update -y
  apt install -y \
    wireguard \
    wireguard-tools \
    resolvconf \
    awscli \
    jq \
    ;
}

# enable forwarding
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

function get_private_key_from_ssm_parameter_store() {
   aws ssm get-parameter \
    --region ${region} \
    --name ${ssm_parameter} \
    --with-decryption \
    --output json | \
   jq -r '.Parameter.Value' | \
   tee /etc/wireguard/wg0.conf &> /dev/null
}

function enable_wireguard_service() {
  # I think you don't need to enable kernel module in 20.04
  # modprobe wireguard
  wg-quick up wg0
  wg show
  systemctl enable wg-quick@wg0
}

function clean_up() {
  # remove this script
  rm -f /var/lib/cloud/instance/scripts/part-001
}

function main() {
  install_packages
  tune_kernel_parameters
  get_private_key_from_ssm_parameter_store
  enable_wireguard_service
  clean_up
}

main
