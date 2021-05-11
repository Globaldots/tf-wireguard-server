resource "aws_ssm_document" "main" {
  name          = "wireguard-server-reload-${var.name_suffix}"
  document_type = "Command"
  target_type   = "/AWS::AutoScaling::AutoScalingGroup"
  permissions = {
    type        = "Share"
    account_ids = "${data.aws_caller_identity.current.account_id}"
  }

  content = <<-EOT
    {
      "schemaVersion": "1.2",
      "description": "Reload wireguard server configuration file.",
      "parameters": {
      },
      "runtimeConfig": {
        "aws:runShellScript": {
          "properties": [
            {
              "id": "0.aws:runShellScript",
              "runCommand": ["wg addconf ${local.wg_interface_name} <(wg-quick strip ${local.wg_interface_name})"]
            }
          ]
        }
      }
    }
  EOT

  tags = var.tags
}
