[Interface]
# Name = ${wg_peer_name}
PrivateKey = <PASTE YOUR PRIVATE KEY HERE>
Address = ${wg_peer_ip}
DNS = ${wg_peer_dns}
MTU = ${wg_peer_mtu}

[Peer]
# Name = server ${wg_server_name}
PublicKey = ${wg_server_public_key}
AllowedIPs = ${wg_peer_allowed_subnets}
Endpoint = ${wg_server_endpoint}
PersistentKeepalive = 25
