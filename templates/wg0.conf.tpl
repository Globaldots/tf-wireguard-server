[Interface]
# Name = server ${name}
Address = ${address}
ListenPort = 51820
MTU = ${mtu}

PreUp = aws s3 cp s3://${s3_bucket_name}/${wg_interface_name}.conf  /etc/wireguard/ --region ${region}
%{if wg_bounce_server_mode ~}
PostUp = iptables -t nat -A POSTROUTING -s ${cidr} -o ${host_main_interface_name} -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s ${cidr} -o ${host_main_interface_name} -j MASQUERADE
%{ endif ~}

PrivateKey = ${private_key}
DNS = ${dns_server}

%{ for peer, config in peers ~}
[Peer]
# Name = ${peer}
PublicKey = ${config.public_key}
AllowedIPs = ${config.allowed_ips}
PersistentKeepalive = 25

%{ endfor ~}
