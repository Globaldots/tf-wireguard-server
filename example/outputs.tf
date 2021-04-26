output "wireguard_server_endpoint" {
  value = module.wg.wireguard_server_endpoint
}

output "wireguard_keys" {
  value = {
    private = wireguard_asymmetric_key.wg_key_pair.private_key
    public  = wireguard_asymmetric_key.wg_key_pair.public_key
  }
  sensitive = true
}
