# Create encrypted parameter in AWS SSM Parameter Store
resource "aws_ssm_parameter" "this" {
  name = format("%s%s", var.ssm_secret_prefix, local.name)
  type = "SecureString"

  # TODO: replace with wireguard_config_document datasource of OJFord/wireguard provider:
  # ref.https://registry.terraform.io/providers/OJFord/wireguard/latest/docs/data-sources/config_document
  value = templatefile(
    "${path.module}/templates/wg0.conf.tmpl",
    {
      name          = var.name_prefix
      region        = var.aws_region
      ssm_parameter = var.ssm_parameter
      address       = var.wg_address
      listen_port   = var.wg_listen_port
      cidr          = var.wg_cidr
      private_key   = var.wg_private_key
      dns_server    = var.dns_server
      peers         = var.wg_peers
    }
  )
}
