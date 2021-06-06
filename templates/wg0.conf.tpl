##############################################
# Managed by Terraform. Don't edit manually! #
##############################################

[Interface]
# Name = server ${name}
Address = ${address}
ListenPort = 51820
MTU = ${mtu}

PreUp = aws s3 cp s3://${s3_bucket_name}/${wg_interface_name}.conf /etc/wireguard/ --region ${region} | /usr/bin/logger -t wg-preup-awscli
PostUp = /usr/local/bin/wg-manage-iptables ${wg_interface_name} up 2>&1 | /usr/bin/logger -t wg-postup-manage-iptables
PostDown = /usr/local/bin/wg-manage-iptables ${wg_interface_name} down 2>&1 | /usr/bin/logger -t wg-postdown-manage-iptables

PrivateKey = ${private_key}
DNS = ${dns_server}

%{ for peer, config in peers ~}
[Peer]
# Name = ${peer}
PublicKey = ${config.public_key}
AllowedIPs = ${config.peer_ip} # AllowSubnetsAccess = ${config.allowed_subnets_str}
PersistentKeepalive = 25

%{ endfor ~}
