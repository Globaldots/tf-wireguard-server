[Interface]
# Name = ${client_name}
PrivateKey = <PASTE YOUR PRIVATE KEY HERE>
Address = ${allowed_ips}
DNS = ${dns}
MTU = ${mtu}

[Peer]
# Name = server ${name}
PublicKey = ${public_key}
AllowedIPs = ${wg_cidr}
Endpoint = ${endpoint}
PersistentKeepalive = 25
