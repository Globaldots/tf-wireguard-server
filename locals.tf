locals {
  wg_server_name             = "wireguard-${var.name_suffix}"
  wg_identification_tag_name = "wireguard-server-name"
  wg_interface_name          = substr("wg-${var.name_suffix}", 0, 15)
  user_data = base64encode(
    templatefile(
      "${path.module}/templates/userdata.sh.tpl",
      {
        region                             = data.aws_region.current.name
        s3_bucket_name                     = aws_s3_bucket.main.id
        interface_name                     = local.wg_interface_name
        host_main_interface_name           = var.ec2_instance_main_interface_name
        enable_prometheus_exporters        = var.enable_prometheus_exporters
        enable_cloudwatch_monitoring       = var.enable_cloudwatch_monitoring
        wg_server_name                     = local.wg_server_name
        cloudwatch_agent_metrics_namespace = local.cloudwatch_agent_metrics_namespace
      }
    )
  )
  ec2_iam_policy_names = concat(var.ec2_iam_policy_names, [
    "CloudWatchAgentServerPolicy", "AmazonSSMManagedInstanceCore", "AmazonSSMDirectoryServiceAccess"
  ])

  # Build peers map with both existing and generated keys
  wg_peers = {
    for k, v in var.wg_peers :
    k => merge(v, try({ public_key = wireguard_asymmetric_key.generated[k].public_key }, {}))
  }

  // TODO: fix problem when client config isn't correctly generated if allowed_ips contains multiple values
  wireguard_client_configs = [for key, value in local.wg_peers :
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
  prom_exporters_ports               = [9100, 9586]
  ssm_document_name                  = "wireguard-server-reload-${var.name_suffix}"
  cloudwatch_agent_metrics_namespace = "CWAgent-wireguard-${var.name_suffix}"
}

# Generate a key pair for users with missing public keys
resource "wireguard_asymmetric_key" "generated" {
  for_each = toset(
    [
      for k, v in var.wg_peers : k
      if try(v.public_key, "") == ""
    ]
  )
}
