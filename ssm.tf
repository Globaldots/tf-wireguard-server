resource "aws_ssm_document" "main" {
  name          = local.ssm_document_name
  document_type = "Command"
  target_type   = "/AWS::EC2::Instance"
  permissions = {
    type        = "Share"
    account_ids = "${data.aws_caller_identity.current.account_id}"
  }

  content = <<-EOT
{
   "schemaVersion": "2.2",
   "description": "Reload wireguard server (${var.name_suffix})",
   "parameters": {},
   "mainSteps": [
      {
         "action": "aws:runShellScript",
         "name": "Reload",
         "inputs": {
            "runCommand": [
              "aws s3 cp s3://${aws_s3_bucket.main.id}/${local.wg_interface_name}.conf  /etc/wireguard/ --region ${data.aws_region.current.name}",
              "/bin/bash -c \"wg syncconf ${local.wg_interface_name} <(wg-quick strip ${local.wg_interface_name})\""
            ]
         }
      }
   ]
}
EOT

  tags = var.tags
}
