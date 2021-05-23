locals {
  wg_server_name             = "wireguard-${var.name_suffix}"
  wg_identification_tag_name = "wireguard-server-name"
  wg_interface_name          = substr("wg-${var.name_suffix}", 0, 15)
  user_data = base64encode(
    templatefile(
      "${path.module}/templates/userdata.sh.tpl",
      {
        region         = data.aws_region.current.name
        s3_bucket_name = aws_s3_bucket.main.id
        interface_name = local.wg_interface_name
      }
    )
  )
  ec2_iam_policy_names = concat(var.ec2_iam_policy_names, [
    "CloudWatchAgentServerPolicy", "AmazonSSMManagedInstanceCore", "AmazonSSMDirectoryServiceAccess"
  ])
  // TODO: fix problem when client config isn't correctly generated if allowed_ips contains multiple values
  wireguard_client_configs = [for key, value in var.wg_peers :
    templatefile(
      "${path.module}/templates/wg0-client.conf.tpl",
      {
        client_name = key
        dns         = var.wg_dns_server
        mtu         = var.wg_mtu
        name        = local.wg_server_name
        public_key  = var.wg_public_key
        allowed_ips = split(",", replace(value.allowed_ips, " ", ""))[0]
        wg_cidr     = var.wg_cidr
        endpoint    = "${aws_route53_record.main.fqdn}:${contains(var.wg_listen_ports, "4500") ? 4500 : var.wg_listen_ports[0]}"
      }
    )
  ]
  prom_exporters_ports = [9100, 9586]
  ssm_document_name    = "wireguard-server-reload-${var.name_suffix}"
}
