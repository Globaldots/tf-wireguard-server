#!/bin/sh

set -xeu

# Install Wireguard and tools
install_packages() {
  amazon-linux-extras install epel -y
  curl --tlsv1.2 --retry 3 --retry-delay 5 -Svo /etc/yum.repos.d/jdoss-wireguard-epel-7.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
  yum update -y && yum install "kernel-devel-uname-r == $(uname -r)" -y
  yum install -y ipset wireguard-dkms wireguard-tools
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
  aws s3 cp "s3://${s3_bucket_name}/${wg_interface_name}.conf" /etc/wireguard --region "${region}"
}

add_wireguard_iptables_script() {
  cat <<'EOT' >> /usr/local/bin/wg-manage-iptables
#!/bin/sh

set -u

WG_INTERFACE_NAME="$${1}"
ACTION="$${2}"

WG_CONFIGURATION_FOLDER="/etc/wireguard"
IPTABLES_RULE_COMMENT="Wireguard - $${WG_INTERFACE_NAME}"

validate_input() {
  if [ ! "$${ACTION}" = "up" ] && [ ! "$${ACTION}" = "down" ]; then
    echo "ERROR | Only 'up' or 'down' actions are supported"
    exit 1
  fi

  if [ "$${WG_INTERFACE_NAME}" = "" ]; then
    echo "ERROR | Passed empty Wireguard interface name"
    exit 1
  fi
}

clean_up_wg_iptables_rules() {
  iptables-save | grep -v "$${IPTABLES_RULE_COMMENT}" | iptables-restore
  return $${?}
}

# Arguments: 
#   $${1} - subnet in CIDR notation (e.x. 10.10.10.0/24)
create_wg_ip_set() {
  ipset create wg hash:net
  ipset add wg "$${1}"
}

# Arguments: 
#   $${1} - subnet or IP-address in CIDR notation (e.x. 10.10.10.0/24)
addr_is_in_ip_set() {
  ipset test wg "$${1}" > /dev/null 2>&1
  return $${?}
}

# Arguments:
#   $${1} - iptables rule to test (e.x. -t nat -A POSTROUTING -s 10.0.0.0/8 -d 0.0.0.0/0 -j MASQUERADE)
check_if_iptables_rule_exists() {
  args=$(echo "$${1}" | sed 's/--delete/--append/g')
  iptables --check "$${args}" > /dev/null 2>&1
  return $${?}
}

clean_up() {
  ipset destroy wg > /dev/null 2>&1 || true
}

main() {
  echo "INFO | Starting"
  echo "==============================================================================="
  validate_input
  clean_up_wg_iptables_rules
  last_exist_code=$${?}

  if [ ! "$${last_exist_code}" -eq 0 ]; then
    echo "WARN | Failed to clean up existing iptables rules"
  fi
  
  if [ "$${ACTION}" = "down" ]; then
    return $${last_exist_code}
  fi

  # isolate all clients by default
  iptables --insert FORWARD -m comment --comment "$${IPTABLES_RULE_COMMENT}" -i "$${WG_INTERFACE_NAME}" -o "$${WG_INTERFACE_NAME}" -j DROP

  WG_SERVER_ADDR="$(grep -oE "^Address\s?=.+$" "$${WG_CONFIGURATION_FOLDER}/$${WG_INTERFACE_NAME}.conf" | cut -d'=' -f2 | xargs )"
  if ! (echo "$${WG_SERVER_ADDR}" | grep -qE '^([0-9]{1,3}\.){1,3}[0-9]{1,3}/[0-9]{1,2}$'); then 
       echo "WARN | Failed to parse server address '$${WG_SERVER_ADDR}'"
  fi
  create_wg_ip_set "$${WG_SERVER_ADDR}"

  ADDRESSES="$(grep -oE "^AllowedIPs\s?=.+$" "$${WG_CONFIGURATION_FOLDER}/$${WG_INTERFACE_NAME}.conf")"
  echo "$${ADDRESSES}" | while IFS= read -r line; do 
    SOURCE_ADDR="$(echo "$${line}" | cut -d'#' -f1 | cut -d'=' -f2 | xargs)"
    DEST_ADDRS="$(echo "$${line}" | cut -d'#' -f2 | cut -d'=' -f2 | sed 's/ //g')"
    ISOLATED="$(echo "$${line}" | cut -d'#' -f3 | cut -d'=' -f2 | xargs)"

    # TODO: add validation for IPv6
    if ! (addr_is_in_ip_set "$${SOURCE_ADDR}"); then
      echo "WARN | Peer address '$${SOURCE_ADDR}' is not within Wireguard network '$${WG_SERVER_ADDR}'"
      continue
    fi
    if ! (echo "$${SOURCE_ADDR}" | grep -qE '^([0-9]{1,3}\.){1,3}[0-9]{1,3}/[0-9]{1,2}$'); then 
      echo "WARN | Failed to parse peer address '$${SOURCE_ADDR}'"
      continue
    fi
    if ! (echo "$${DEST_ADDRS}" | grep -qE  '^(([0-9]{1,3}\.){1,3}[0-9]{1,3}/[0-9]{1,2},?)+$'); then 
      echo "WARN | Failed to parse peer's allowed subnets list '$${SOURCE_ADDR}'"
      continue
    fi

    # disable isolation for specific clients
    if [ "$${ISOLATED}" = "false" ]; then
      set -- --insert FORWARD -m comment --comment "$${IPTABLES_RULE_COMMENT}" -i "$${WG_INTERFACE_NAME}" -s "$${SOURCE_ADDR}" -d "$${WG_SERVER_ADDR}" -j ACCEPT
      if check_if_iptables_rule_exists "$${*}"; then
        echo "INFO | Rule '$${*} can't be added because it already exists'"
      else
        if ! (iptables "$${@}"); then
          echo "WARN | Failed to add iptables rule '$${*}'"
        fi
      fi
    fi
     
    for dest_addr in $(echo "$${DEST_ADDRS}" | sed "s/,/ /g"); do
      if addr_is_in_ip_set "$${dest_addr}"; then
        echo "INFO | Subnet '$${dest_addr}' is within Wireguard network '$${WG_SERVER_ADDR}'. Skipping iptables SNAT rule"
        continue
      fi
   
      set -- -t nat --append POSTROUTING -m comment --comment "$${IPTABLES_RULE_COMMENT}" -s "$${SOURCE_ADDR}" -d "$${dest_addr}" -j MASQUERADE
      if check_if_iptables_rule_exists "$${*}"; then
        echo "INFO | Rule '$${*} can't be added because it already exists'"
        continue
      fi

      if ! (iptables "$${@}"); then
        echo "WARN | Failed to add iptables rule '$${*}'"
        continue
      fi

      echo "INFO | Sucessfully added iptables rule '$${*}'"
    done
  done
}

trap clean_up INT TERM EXIT
main
EOT
chown "$(whoami)" /usr/local/bin/wg-manage-iptables
chmod +x /usr/local/bin/wg-manage-iptables
}

# Enable Wireguard
enable_wireguard_service() {
  wg-quick up "${wg_interface_name}"
  wg show
  systemctl enable "wg-quick@${wg_interface_name}"
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
  systemctl start docker
  
  mkdir -p /tmp/prometheus-wireguard-exporter && \
    chmod 777 /tmp/prometheus-wireguard-exporter
  docker run --rm --entrypoint /bin/sh -v "/tmp/prometheus-wireguard-exporter:/mnt" \
    mindflavor/prometheus-wireguard-exporter \
    -c "cp /usr/local/bin/prometheus_wireguard_exporter /mnt/"
  
  mv /tmp/prometheus-wireguard-exporter/prometheus_wireguard_exporter /usr/local/bin && \
    rm -rf /tmp/prometheus-wireguard-exporter
  chown "$(whoami)" /usr/local/bin/prometheus_wireguard_exporter && \
    chmod +x /usr/local/bin/prometheus_wireguard_exporter

  systemctl stop docker
  systemctl disable docker
  systemctl stop docker.socket
  systemctl disable docker.socket

  cat <<'EOT' >> /lib/systemd/system/wireguard_exporter.service
[Unit]
Description=Prometheus WireGuard Exporter
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=root
Group=root
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus_wireguard_exporter -n /etc/wireguard/${wg_interface_name}.conf

[Install]
WantedBy=multi-user.target
EOT

chmod 644 /lib/systemd/system/wireguard_exporter.service
systemctl daemon-reload
systemctl enable wireguard_exporter.service
systemctl start wireguard_exporter.service
# Remove Docker SNAT iptables rule to avoid potantial issues in case if chosen Wireguard network will overlap Docker network
iptables -t nat -D POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
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
          "${ec2_main_interface_name}"
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
            "log_group_name": "${cloudwatch_log_groups.general}",
            "log_stream_name": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name":  "${cloudwatch_log_groups.general}",
            "log_stream_name": "/var/log/messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name":  "${cloudwatch_log_groups.general}",
            "log_stream_name": "/var/log/secure",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/yum.log",
            "log_group_name":  "${cloudwatch_log_groups.general}",
            "log_stream_name": "/var/log/yum",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name":  "${cloudwatch_log_groups.general}",
            "log_stream_name": "/var/log/cloud-init-output",
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
  add_wireguard_iptables_script
  enable_wireguard_service
  
  %{if prometheus_exporters_enable ~}
  enable_prom_node_exporter
  enable_prom_wireguard_exporter
  %{ endif ~}

  %{if cloudwatch_monitoring_enable ~}
  enable_cloudwatch_agent
  %{ endif ~}
}

main
