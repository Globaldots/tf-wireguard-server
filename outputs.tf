output "wireguard_server_ip" {
  value = aws_eip.this.public_ip
}

output "wireguard_server_port" {
  value = var.wg_listen_port
}

output "wireguard_server_endpoint" {
  value = format("%s:%s", aws_eip.this.public_ip, var.wg_listen_port)
}

output "ssm_parameter" {
  value = local.name
}
