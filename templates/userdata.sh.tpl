#!/bin/sh

set -xeu

# Install Wireguard and tools
install_packages() {
  amazon-linux-extras install epel -y
  curl --tlsv1.2 --retry 3 --retry-delay 5 -Svo /etc/yum.repos.d/jdoss-wireguard-epel-7.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
  yum update -y && yum install "kernel-devel-uname-r == $(uname -r)" -y
  yum install -y wireguard-dkms wireguard-tools
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
  mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
  cat <<'EOT' >> /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 10,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "metrics": {
    "namespace": "${cloudwatch_agent_metrics_namespace}",
    "metrics_collected": {
      "cpu": {
        "resources": [
          "*"
        ],
        "measurement": [
          "cpu_usage_nice",
          "cpu_usage_idle",
          "cpu_usage_guest"
        ],
        "totalcpu": false,
        "metrics_collection_interval": 10
      },
      "disk": {
        "resources": [
          "/"
        ],
        "measurement": [
          "free",
          "total",
          "used"
        ],
          "ignore_file_system_types": [
          "sysfs", "devtmpfs"
        ],
        "metrics_collection_interval": 60
      },
      "diskio": {
        "resources": [
          "*"
        ],
        "measurement": [
          "reads",
          "writes",
          "read_time",
          "write_time",
          "io_time"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used",
          "swap_free",
          "swap_used_percent"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used",
          "mem_cached",
          "mem_total"
        ],
        "metrics_collection_interval": 1
      },
      "net": {
        "resources": [
          "${host_main_interface_name}"
        ],
        "measurement": [
          "bytes_sent",
          "bytes_recv",
          "drop_in",
          "drop_out"
        ]
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_syn_sent",
          "tcp_close"
        ],
        "metrics_collection_interval": 60
      },
      "processes": {
        "measurement": [
          "running",
          "sleeping",
          "dead"
        ]
      }
    },
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}",
      "AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
    },
    "aggregation_dimensions" : [["AutoScalingGroupName"], ["InstanceId", "InstanceType"]],
    "force_flush_interval" : 30
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "/var/log/amazon/amazon-cloudwatch-agent",
            "log_stream_name": "${wg_server_name}_{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name":  "/ec2/var/log/messages",
            "log_stream_name": "${wg_server_name}_{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name":  "/ec2/var/log/secure",
            "log_stream_name": "${wg_server_name}_{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/yum.log",
            "log_group_name":  "/ec2/var/log/yum",
            "log_stream_name": "${wg_server_name}_{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "${wg_server_name}_{instance_id}",
    "force_flush_interval" : 15
  }
}
EOT

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
  
  %{if enable_prometheus_exporters ~}
  enable_prom_node_exporter
  enable_prom_wireguard_exporter
  %{ endif ~}

  %{if enable_cloudwatch_monitoring ~}
  enable_cloudwatch_agent
  %{ endif ~}
}

main
