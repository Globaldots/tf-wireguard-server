####################
# Helper variables #
####################
locals {
  wg_server_name             = "wireguard-${var.name_suffix}"
  wg_identification_tag_name = "wireguard-server-name"
  wg_interface_name          = substr("wg-${var.name_suffix}", 0, 15)
  wg_server_address          = var.dns_zone_name == "" ? aws_lb.main.dns_name : aws_route53_record.main[0].fqdn

  # Build peers map with both existing and generated keys
  wg_peers = {
    for k, v in var.wg_peers :
    k => merge(
      v,
      try({ public_key = wireguard_asymmetric_key.generated[k].public_key }, {}),
      { allowed_subnets_str = join(", ", v.allowed_subnets) }
    )
  }

  # EC2
  ec2_iam_policy_names = concat(var.ec2_iam_policy_names, [
    "CloudWatchAgentServerPolicy", "AmazonSSMManagedInstanceCore", "AmazonSSMDirectoryServiceAccess"
  ])

  # SSM
  ssm_document_name = "reload-app-instances-wireguard-${var.name_suffix}"

  # Lambda
  lambda_function_name = "reload-app-instances-wireguard-${var.name_suffix}"

  # Prometheus
  prometheus_exporters_ports = [9100, 9586]

  # Cloudwatch
  cloudwatch_agent_metrics_namespace         = "cw-agent-wireguard-${var.name_suffix}"
  cloudwatch_lambda_status_metric_name       = "lambda-status-${local.lambda_function_name}"
  cloudwatch_ec2_userdata_status_metric_name = "ec2-userdata-status-wireguard-${var.name_suffix}"
  cloudwatch_log_groups = {
    general = "/wireguard-${var.name_suffix}",
    lambda  = "/aws/lambda/${local.lambda_function_name}",
    ssm     = "/aws/ssm/${local.ssm_document_name}",
  }
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

#############
# Templates #
#############
locals {
  ec2_user_data = base64encode(
    templatefile(
      "${path.module}/templates/userdata.sh.tpl",
      {
        region                             = data.aws_region.current.name
        s3_bucket_name                     = aws_s3_bucket.main.id
        ec2_main_interface_name            = var.ec2_instance_main_interface_name
        wg_interface_name                  = local.wg_interface_name
        wg_server_name                     = local.wg_server_name
        prometheus_exporters_enable        = var.prometheus_exporters_enable
        cloudwatch_monitoring_enable       = var.cloudwatch_monitoring_enable
        cloudwatch_agent_metrics_namespace = local.cloudwatch_agent_metrics_namespace
        cloudwatch_log_groups              = local.cloudwatch_log_groups
      }
    )
  )

  wg_client_configs = [for k, v in local.wg_peers :
    templatefile(
      "${path.module}/templates/wg0-client.conf.tpl",
      {
        wg_peer_ip              = v.peer_ip
        wg_peer_dns             = var.wg_dns_server
        wg_peer_mtu             = var.wg_mtu
        wg_peer_name            = k
        wg_peer_allowed_subnets = join(", ", v.allowed_subnets)
        wg_server_name          = local.wg_server_name
        wg_server_public_key    = var.wg_public_key
        wg_server_endpoint      = contains(var.wg_listen_ports, "4500") ? "${local.wg_server_address}:4500" : "${local.wg_server_address}:${var.wg_listen_ports[0]}"
      }
    )
  ]

  wg_server_config = templatefile("${path.module}/templates/wg0.conf.tpl", {
    name              = local.wg_server_name
    address           = "${cidrhost(var.wg_cidr, 1)}/${replace(var.wg_cidr, "/.*\\//", "")}"
    s3_bucket_name    = aws_s3_bucket.main.id
    region            = aws_s3_bucket.main.region
    private_key       = var.wg_private_key
    dns_server        = var.wg_dns_server
    peers             = local.wg_peers
    mtu               = var.wg_mtu
    wg_interface_name = local.wg_interface_name
  })
}
