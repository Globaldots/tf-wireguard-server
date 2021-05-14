#!/bin/sh

set -xeu

# Install Wireguard and tools
install_packages() {
  amazon-linux-extras install epel -y
  curl --tlsv1.2 --retry 3 --retry-delay 5 -Svo /etc/yum.repos.d/jdoss-wireguard-epel-7.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
  yum update -y && yum install -y \
    wireguard-dkms \
    wireguard-tools \
    ;
}

# Enable IPv4/6 forwarding
tune_kernel_parameters() {
  tee /etc/sysctl.d/100-wireguard.conf << EOF
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
net.ipv4.conf.all.proxy_arp=1
EOF

  sysctl --system

tee /etc/security/limits.d/100-wireguard.conf << EOF
* hard nofile 64000
* soft nofile 64000
root hard nofile 64000
root soft nofile 64000
EOF
}

# Download Wireguard configuration
download_wg_conf() {
  aws s3 cp s3://${s3_bucket_name}/${interface_name}.conf /etc/wireguard --region ${region}
}

# Enable Wireguard
enable_wireguard_service() {
  wg-quick up ${interface_name}
  wg show
  systemctl enable wg-quick@${interface_name}
}

# Prometheus Node Exporter
enable_prom_node_exporter() {
  curl --tlsv1.2 --retry 3 --retry-delay 5 -Svo /etc/yum.repos.d/_copr_ibotty-prometheus-exporters.repo https://copr.fedorainfracloud.org/coprs/ibotty/prometheus-exporters/repo/epel-7/ibotty-prometheus-exporters-epel-7.repo
  yum install node_exporter -y
  systemctl enable node_exporter
  systemctl start node_exporter
}

# Prometheus Wireguard Exporter
enable_prom_wireguard_exporter() {
  yum install docker -y
  systemctl enable docker
  systemctl start docker
  docker run -d --restart unless-stopped --init --net=host --cap-add=NET_ADMIN mindflavor/prometheus-wireguard-exporter
}

# CloudWatch monitoring agent
enable_cloudwatch_agent() {
  yum install amazon-cloudwatch-agent -y
  systemctl enable amazon-cloudwatch-agent
  systemctl start amazon-cloudwatch-agent
}

# Cleanup userdata script
clean_up() {
  rm -f "$0"
}

trap clean_up INT TERM EXIT

# Main
main() {
  install_packages
  tune_kernel_parameters
  download_wg_conf
  enable_wireguard_service
  enable_prom_node_exporter
  enable_prom_wireguard_exporter
  enable_cloudwatch_agent
}

main
