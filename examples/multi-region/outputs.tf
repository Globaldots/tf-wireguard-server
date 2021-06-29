###############################################################################
### COMMON ####################################################################
###############################################################################

output "wireguard_server_keys" {
  description = "Wireguard server public & private keys"
  value = {
    private = wireguard_asymmetric_key.wg_key_pair.private_key
    public  = wireguard_asymmetric_key.wg_key_pair.public_key
  }
  sensitive = true
}

output "wireguard_client_generated_keys" {
  description = "Wireguard client public & private keys"
  value       = wireguard_asymmetric_key.wg_key_pair_clients[*]
  sensitive   = true
}

output "wireguard_server_endpoints" {
  description = "Wireguard DNS endpoint for clients"
  value       = local.wireguard_server_endpoints
}

output "wireguard_server_name" {
  description = "Wireguard server name"
  value       = module.wg-a.wireguard_server_name
}

output "wireguard_server_ports" {
  description = "Wireguard server ports"
  value       = module.wg-a.wireguard_server_ports
}

output "wireguard_client_configs" {
  description = "Example configuration files for Wireguard clients"
  value       = local.wireguard_client_configs
}

###############################################################################
### REGION A ##################################################################
###############################################################################

output "region_a_wireguard_server_endpoints" {
  description = "Wireguard server endpoints"
  value       = module.wg-a.wireguard_server_endpoints
}

output "region_a_launch_template_arn" {
  description = "EC2 launch template ARN"
  value       = module.wg-a.launch_template_arn
}

output "region_a_launch_template_id" {
  description = "EC2 launch template ID"
  value       = module.wg-a.launch_template_id
}

output "region_a_autoscaling_group_arn" {
  description = "EC2 autoscaling group ARN"
  value       = module.wg-a.autoscaling_group_arn
}

output "region_a_autoscaling_group_name" {
  description = "EC2 autoscaling group name"
  value       = module.wg-a.autoscaling_group_name
}

output "region_a_sqs_queue_arn" {
  description = "SQS queue for S3 notifications ARN"
  value       = module.wg-a.sqs_queue_arn
}

output "region_a_sqs_queue_id" {
  description = "SQS queue for S3 notifications ID"
  value       = module.wg-a.sqs_queue_id
}

output "region_a_sqs_queue_dead_letter_arn" {
  description = "SQS dead letter queue for S3 notifications ARN"
  value       = module.wg-a.sqs_queue_dead_letter_arn
}

output "region_a_sqs_queue_dead_letter_id" {
  description = "SQS dead letter queue for S3 notifications ID"
  value       = module.wg-a.sqs_queue_dead_letter_id
}

output "region_a_s3_bucket_arn" {
  description = "Wireguard configuration S3 bucket ARN"
  value       = module.wg-a.s3_bucket_arn
}

output "region_a_s3_bucket_name" {
  description = "Wireguard configuration S3 bucket name"
  value       = module.wg-a.s3_bucket_name
}

output "region_a_s3_bucket_access_logs_arn" {
  description = "Load balancer access logs S3 bucket ARN"
  value       = module.wg-a.s3_bucket_access_logs_arn
}

output "region_a_s3_bucket_access_logs_name" {
  description = "Load balancer access logs S3 bucket name"
  value       = module.wg-a.s3_bucket_access_logs_name
}

output "region_a_lb_arn" {
  description = "Load balancer ARN"
  value       = module.wg-a.lb_arn
}

output "region_a_lb_dns_name" {
  description = "Load balancer DNS name"
  value       = module.wg-a.lb_dns_name
}

output "region_a_iam_role_arn" {
  description = "ARN of IAM role to access S3 bucket"
  value       = module.wg-a.iam_role_arn
}

output "region_a_iam_role_name" {
  description = "Name of IAM role to access S3 bucket"
  value       = module.wg-a.iam_role_name
}

output "region_a_iam_instance_profile_arn" {
  description = "ARN of IAM instance profile to access S3 bucket"
  value       = module.wg-a.iam_instance_profile_arn
}

output "region_a_iam_instance_profile_id" {
  description = "ID of IAM instance profile to access S3 bucket"
  value       = module.wg-a.iam_instance_profile_id
}

###############################################################################
### REGION B ##################################################################
###############################################################################

output "region_b_wireguard_server_endpoints" {
  description = "Wireguard server endpoints"
  value       = module.wg-b.wireguard_server_endpoints
}

output "region_b_launch_template_arn" {
  description = "EC2 launch template ARN"
  value       = module.wg-b.launch_template_arn
}

output "region_b_launch_template_id" {
  description = "EC2 launch template ID"
  value       = module.wg-b.launch_template_id
}

output "region_b_autoscaling_group_arn" {
  description = "EC2 autoscaling group ARN"
  value       = module.wg-b.autoscaling_group_arn
}

output "region_b_autoscaling_group_name" {
  description = "EC2 autoscaling group name"
  value       = module.wg-b.autoscaling_group_name
}

output "region_b_sqs_queue_arn" {
  description = "SQS queue for S3 notifications ARN"
  value       = module.wg-b.sqs_queue_arn
}

output "region_b_sqs_queue_id" {
  description = "SQS queue for S3 notifications ID"
  value       = module.wg-b.sqs_queue_id
}

output "region_b_sqs_queue_dead_letter_arn" {
  description = "SQS dead letter queue for S3 notifications ARN"
  value       = module.wg-b.sqs_queue_dead_letter_arn
}

output "region_b_sqs_queue_dead_letter_id" {
  description = "SQS dead letter queue for S3 notifications ID"
  value       = module.wg-b.sqs_queue_dead_letter_id
}

output "region_b_s3_bucket_arn" {
  description = "Wireguard configuration S3 bucket ARN"
  value       = module.wg-b.s3_bucket_arn
}

output "region_b_s3_bucket_name" {
  description = "Wireguard configuration S3 bucket name"
  value       = module.wg-b.s3_bucket_name
}

output "region_b_s3_bucket_access_logs_arn" {
  description = "Load balancer access logs S3 bucket ARN"
  value       = module.wg-b.s3_bucket_access_logs_arn
}

output "region_b_s3_bucket_access_logs_name" {
  description = "Load balancer access logs S3 bucket name"
  value       = module.wg-b.s3_bucket_access_logs_name
}

output "region_b_lb_arn" {
  description = "Load balancer ARN"
  value       = module.wg-b.lb_arn
}

output "region_b_lb_dns_name" {
  description = "Load balancer DNS name"
  value       = module.wg-b.lb_dns_name
}

output "region_b_iam_role_arn" {
  description = "ARN of IAM role to access S3 bucket"
  value       = module.wg-b.iam_role_arn
}

output "region_b_iam_role_name" {
  description = "Name of IAM role to access S3 bucket"
  value       = module.wg-b.iam_role_name
}

output "region_b_iam_instance_profile_arn" {
  description = "ARN of IAM instance profile to access S3 bucket"
  value       = module.wg-b.iam_instance_profile_arn
}

output "region_b_iam_instance_profile_id" {
  description = "ID of IAM instance profile to access S3 bucket"
  value       = module.wg-b.iam_instance_profile_id
}
