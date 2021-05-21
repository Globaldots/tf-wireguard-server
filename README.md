## tf-wireguard-server
This is the main code to deploy Wireguard VPN Server on top of AWS Amazon EC2, which includes
(ASG, ENI, EIP, launch template, and many more).

Please check folder example/ to see how this module can be provisioned

Please, find deployment instruction in README.md file of repository root.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_attachment) | resource |
| [aws_autoscaling_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_cloudwatch_metric_alarm.cpu_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.status_checks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_instance_profile.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_notification.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_object.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) | resource |
| [aws_s3_bucket_public_access_block.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.instance-egress-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.instance-ingress-1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.instance-ingress-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.instance-ingress-3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sns_topic.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.text](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.main_dead_letter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_ssm_document.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_ami.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_kms_alias.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_kms_alias.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnet.main_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.main_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bounce_server"></a> [bounce\_server](#input\_bounce\_server) | Bounce server mode. Ref: https://github.com/pirate/wireguard-docs#bounce-server | `bool` | `false` | no |
| <a name="input_cloudwatch_alerts_emails"></a> [cloudwatch\_alerts\_emails](#input\_cloudwatch\_alerts\_emails) | Email addresses to get monitoring alerts from CloudWatch | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_alerts_phone_numbers"></a> [cloudwatch\_alerts\_phone\_numbers](#input\_cloudwatch\_alerts\_phone\_numbers) | Phone numbers to get monitoring alerts from CloudWatch | `list(string)` | `[]` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Route53 DNS zone name for Wireguard server endpoint | `string` | n/a | yes |
| <a name="input_ec2_iam_policy_names"></a> [ec2\_iam\_policy\_names](#input\_ec2\_iam\_policy\_names) | Additional IAM policies to assign to EC2 instances through instance profile | `list(string)` | `[]` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | EC2 instance type | `string` | `"t3a.micro"` | no |
| <a name="input_enable_termination_protection"></a> [enable\_termination\_protection](#input\_enable\_termination\_protection) | Enable termination protection for resources | `bool` | `true` | no |
| <a name="input_host_nic"></a> [host\_nic](#input\_host\_nic) | Default Network Interface Card on a host system | `string` | `"eth0"` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix to be added to all resources | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | VPC private subnet CIDRs to create EC2 instances in (AZs of public & private subnets should match) | `list(string)` | n/a | yes |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | VPC public subnet CIDRs to create NLB in (multiple subnets are used for HA, AZs of public & private subnets should match) | `list(string)` | n/a | yes |
| <a name="input_s3_bucket_name_prefix"></a> [s3\_bucket\_name\_prefix](#input\_s3\_bucket\_name\_prefix) | Prefix to be added to S3 bucket name | `string` | n/a | yes |
| <a name="input_ssh_keypair_name"></a> [ssh\_keypair\_name](#input\_ssh\_keypair\_name) | EC2 SSH keypair name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS VPC ID | `string` | n/a | yes |
| <a name="input_wg_allow_connections_from_subnets"></a> [wg\_allow\_connections\_from\_subnets](#input\_wg\_allow\_connections\_from\_subnets) | Restrict Wireguard server availability to defined subnets | `list(string)` | n/a | yes |
| <a name="input_wg_cidr"></a> [wg\_cidr](#input\_wg\_cidr) | Wireguard network subnet CIDR | `string` | `"10.0.44.0/24"` | no |
| <a name="input_wg_dns_server"></a> [wg\_dns\_server](#input\_wg\_dns\_server) | DNS server for Wireguard network | `string` | `"8.8.8.8"` | no |
| <a name="input_wg_ha_instance_desired_count"></a> [wg\_ha\_instance\_desired\_count](#input\_wg\_ha\_instance\_desired\_count) | Desired number of Wiregard instances (HA configuration) | `number` | `2` | no |
| <a name="input_wg_ha_instance_max_count"></a> [wg\_ha\_instance\_max\_count](#input\_wg\_ha\_instance\_max\_count) | Maximum number of Wiregard instances (HA configuration) | `number` | `2` | no |
| <a name="input_wg_ha_instance_min_count"></a> [wg\_ha\_instance\_min\_count](#input\_wg\_ha\_instance\_min\_count) | Minimum number of Wiregard instances (HA configuration) | `number` | `2` | no |
| <a name="input_wg_listen_ports"></a> [wg\_listen\_ports](#input\_wg\_listen\_ports) | Wireguard listen ports | `list(string)` | <pre>[<br>  "51820",<br>  "4500",<br>  "53"<br>]</pre> | no |
| <a name="input_wg_mtu"></a> [wg\_mtu](#input\_wg\_mtu) | MTU value for Wireguard network | `number` | `"1420"` | no |
| <a name="input_wg_peers"></a> [wg\_peers](#input\_wg\_peers) | Wireguard clients (peers) configuration | `map(object({ public_key = string, allowed_ips = string }))` | `{}` | no |
| <a name="input_wg_private_key"></a> [wg\_private\_key](#input\_wg\_private\_key) | WireGuard server private key | `string` | n/a | yes |
| <a name="input_wg_public_key"></a> [wg\_public\_key](#input\_wg\_public\_key) | WireGuard server public key | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn) | EC2 autoscaling group ARN |
| <a name="output_autoscaling_group_name"></a> [autoscaling\_group\_name](#output\_autoscaling\_group\_name) | EC2 autoscaling group name |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | ARN of IAM instance profile to access S3 bucket |
| <a name="output_iam_instance_profile_id"></a> [iam\_instance\_profile\_id](#output\_iam\_instance\_profile\_id) | ID of IAM instance profile to access S3 bucket |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of IAM role to access S3 bucket |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of IAM role to access S3 bucket |
| <a name="output_launch_template_arn"></a> [launch\_template\_arn](#output\_launch\_template\_arn) | EC2 launch template ARN |
| <a name="output_launch_template_id"></a> [launch\_template\_id](#output\_launch\_template\_id) | EC2 launch template ID |
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | Load balancer ARN |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | Load balancer DNS name |
| <a name="output_s3_bucket_access_logs_arn"></a> [s3\_bucket\_access\_logs\_arn](#output\_s3\_bucket\_access\_logs\_arn) | Load balancer access logs S3 bucket ARN |
| <a name="output_s3_bucket_access_logs_name"></a> [s3\_bucket\_access\_logs\_name](#output\_s3\_bucket\_access\_logs\_name) | Load balancer access logs S3 bucket name |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | Wireguard configuration S3 bucket ARN |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | Wireguard configuration S3 bucket name |
| <a name="output_sqs_queue_arn"></a> [sqs\_queue\_arn](#output\_sqs\_queue\_arn) | SQS queue for S3 notifications ARN |
| <a name="output_sqs_queue_dead_letter_arn"></a> [sqs\_queue\_dead\_letter\_arn](#output\_sqs\_queue\_dead\_letter\_arn) | SQS dead letter queue for S3 notifications ARN |
| <a name="output_sqs_queue_dead_letter_id"></a> [sqs\_queue\_dead\_letter\_id](#output\_sqs\_queue\_dead\_letter\_id) | SQS dead letter queue for S3 notifications ID |
| <a name="output_sqs_queue_id"></a> [sqs\_queue\_id](#output\_sqs\_queue\_id) | SQS queue for S3 notifications ID |
| <a name="output_wireguard_client_configs"></a> [wireguard\_client\_configs](#output\_wireguard\_client\_configs) | Example configuration files for Wireguard clients |
| <a name="output_wireguard_server_endpoints"></a> [wireguard\_server\_endpoints](#output\_wireguard\_server\_endpoints) | Wireguard server endpoints |
| <a name="output_wireguard_server_host"></a> [wireguard\_server\_host](#output\_wireguard\_server\_host) | Wireguard server host |
| <a name="output_wireguard_server_name"></a> [wireguard\_server\_name](#output\_wireguard\_server\_name) | Wireguard server name |
| <a name="output_wireguard_server_ports"></a> [wireguard\_server\_ports](#output\_wireguard\_server\_ports) | Wireguard server ports |
