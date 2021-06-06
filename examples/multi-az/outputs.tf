output "wireguard_keys" {
  description = "Wireguard public & private keys"
  value = {
    private = wireguard_asymmetric_key.wg_key_pair.private_key
    public  = wireguard_asymmetric_key.wg_key_pair.public_key
  }
  sensitive = true
}

output "wireguard_server_name" {
  description = "Wireguard server name"
  value       = module.wg.wireguard_server_name
}

output "wireguard_server_host" {
  description = "Wireguard server host"
  value       = module.wg.wireguard_server_host
}

output "wireguard_server_ports" {
  description = "Wireguard server ports"
  value       = module.wg.wireguard_server_ports
}

output "wireguard_server_endpoints" {
  description = "Wireguard server endpoints"
  value       = module.wg.wireguard_server_endpoints
}

output "wireguard_client_configs" {
  description = "Example configuration files for Wireguard clients"
  value       = module.wg.wireguard_client_configs
}

output "launch_template_arn" {
  description = "EC2 launch template ARN"
  value       = module.wg.launch_template_arn
}

output "launch_template_id" {
  description = "EC2 launch template ID"
  value       = module.wg.launch_template_id
}

output "autoscaling_group_arn" {
  description = "EC2 autoscaling group ARN"
  value       = module.wg.autoscaling_group_arn
}

output "autoscaling_group_name" {
  description = "EC2 autoscaling group name"
  value       = module.wg.autoscaling_group_name
}

output "sqs_queue_arn" {
  description = "SQS queue for S3 notifications ARN"
  value       = module.wg.sqs_queue_arn
}

output "sqs_queue_id" {
  description = "SQS queue for S3 notifications ID"
  value       = module.wg.sqs_queue_id
}

output "sqs_queue_dead_letter_arn" {
  description = "SQS dead letter queue for S3 notifications ARN"
  value       = module.wg.sqs_queue_dead_letter_arn
}

output "sqs_queue_dead_letter_id" {
  description = "SQS dead letter queue for S3 notifications ID"
  value       = module.wg.sqs_queue_dead_letter_id
}

output "s3_bucket_arn" {
  description = "Wireguard configuration S3 bucket ARN"
  value       = module.wg.s3_bucket_arn
}

output "s3_bucket_name" {
  description = "Wireguard configuration S3 bucket name"
  value       = module.wg.s3_bucket_name
}

output "s3_bucket_access_logs_arn" {
  description = "Load balancer access logs S3 bucket ARN"
  value       = module.wg.s3_bucket_access_logs_arn
}

output "s3_bucket_access_logs_name" {
  description = "Load balancer access logs S3 bucket name"
  value       = module.wg.s3_bucket_access_logs_name
}

output "lb_arn" {
  description = "Load balancer ARN"
  value       = module.wg.lb_arn
}

output "lb_dns_name" {
  description = "Load balancer DNS name"
  value       = module.wg.lb_dns_name
}

output "iam_role_arn" {
  description = "ARN of IAM role to access S3 bucket"
  value       = module.wg.iam_role_arn
}

output "iam_role_name" {
  description = "Name of IAM role to access S3 bucket"
  value       = module.wg.iam_role_name
}

output "iam_instance_profile_arn" {
  description = "ARN of IAM instance profile to access S3 bucket"
  value       = module.wg.iam_instance_profile_arn
}

output "iam_instance_profile_id" {
  description = "ID of IAM instance profile to access S3 bucket"
  value       = module.wg.iam_instance_profile_id
}

# output "snat_rule_addresses" {
#   value = module.wg.snat_rule_addresses
# }
