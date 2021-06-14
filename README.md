[]: # (BEGIN_TF_DOCS)
## tf-wireguard-server
WireGuard® is an extremely simple yet fast and modern VPN that utilizes state-of-the-art cryptography. It aims to be faster, simpler, leaner, and more useful than IPsec, while avoiding the massive headache. It intends to be considerably more performant than OpenVPN.

This repository contains Terraform code to provision Wireguard server in a highly-available, scalable and secure manner, utilizing benefits of AWS infrastructure. The solution is built on top of such services as EC2, NLB, S3, SQS, Lambda, SSM, CloudWatch, SNS and more.

### Design
![Wireguard Multi AZ design](./docs/aws-wireguard-multi-az-no-app.svg)

Above diagram demonstrates highly-available Wireguard setup in a single AWS region. Reference code is located under `examples/multi-az` folder.

#### Clients connections
Multiple EC2 instances are spread across several availability zones within a region. Clients connections get distributed to the instances through highly-available Network Load Balancer with Route53 DNS record attached (optional).

#### Configuration changes
Wireguard configuration file is being generated by Terraform and stored in S3 bucket with enabled versioning and access logs. Every S3 bucket content change triggers Lambda function through SQS queue. Lambda function executes predefined SSM document on all Wireguard EC2 instances. SSM document is configured to upload the latest configuration file to the instances and reload Wireguard interface.
Also, Wireguard instances have PreUp hook enabled which additionally ensures that they use the latest configuration file available in S3.

### Prerequisites
* Terraform 0.15+
* Terragrunt 0.28.7+ (optional but recommended)
* Configured CLI access to target AWS account

### Quick start
There are multiple examples under `examples` folder. Please, choose the one that fits your needs best. Every example comes with its own `README.md` file.
Example code snippets for simplicity reasons don't define all variables which module exposes. So if you want to get a better understanding of all available options, please review the table below.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.70.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1.0 |
| <a name="requirement_wireguard"></a> [wireguard](#requirement\_wireguard) | 0.1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.70.0 |
| <a name="provider_wireguard"></a> [wireguard](#provider\_wireguard) | 0.1.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_alerts_emails"></a> [cloudwatch\_alerts\_emails](#input\_cloudwatch\_alerts\_emails) | Email addresses to get monitoring alerts from CloudWatch. Ignored when cloudwatch\_monitoring\_enable = false. | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_alerts_phone_numbers"></a> [cloudwatch\_alerts\_phone\_numbers](#input\_cloudwatch\_alerts\_phone\_numbers) | Phone numbers to get monitoring alerts from CloudWatch. Ignored when cloudwatch\_monitoring\_enable = false. | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | For how long CloudWatch will store log files (days) | `number` | `180` | no |
| <a name="input_cloudwatch_monitoring_enable"></a> [cloudwatch\_monitoring\_enable](#input\_cloudwatch\_monitoring\_enable) | Enable CloudWatch monitoring of Wireguard resources | `bool` | `true` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Route53 DNS zone name for Wireguard server endpoint. If not set, AWS LB DNS record is used | `string` | `""` | no |
| <a name="input_ec2_iam_policy_names"></a> [ec2\_iam\_policy\_names](#input\_ec2\_iam\_policy\_names) | Additional IAM policies to assign to EC2 instances through instance profile | `list(string)` | `[]` | no |
| <a name="input_ec2_instance_main_interface_name"></a> [ec2\_instance\_main\_interface\_name](#input\_ec2\_instance\_main\_interface\_name) | EC2 instance main network interface name | `string` | `"eth0"` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | EC2 instance type | `string` | `"t3.micro"` | no |
| <a name="input_enable_termination_protection"></a> [enable\_termination\_protection](#input\_enable\_termination\_protection) | Enable termination protection for resources | `bool` | `true` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix to be added to all resources | `string` | n/a | yes |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | VPC private subnet CIDRs to create EC2 instances in (AZs of public & private subnets should match) | `list(string)` | n/a | yes |
| <a name="input_prometheus_exporters_enable"></a> [prometheus\_exporters\_enable](#input\_prometheus\_exporters\_enable) | Run Prometheus Exporters (Node Exporter & Wireguard Exporter) on EC2 instances | `bool` | `true` | no |
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
| <a name="input_wg_peers"></a> [wg\_peers](#input\_wg\_peers) | Wireguard clients (peers) configuration | `map(object({ public_key = string, peer_ip = string, allowed_subnets = list(string), isolated = bool }))` | `{}` | no |
| <a name="input_wg_private_key"></a> [wg\_private\_key](#input\_wg\_private\_key) | WireGuard server private key | `string` | n/a | yes |
| <a name="input_wg_public_key"></a> [wg\_public\_key](#input\_wg\_public\_key) | WireGuard server public key | `string` | n/a | yes |
| <a name="input_wg_restart_lambda_max_errors_count"></a> [wg\_restart\_lambda\_max\_errors\_count](#input\_wg\_restart\_lambda\_max\_errors\_count) | Lambda which restarts Wireguard instances when configuration changes detected will stop execution if number of errors exceed this value | `number` | `0` | no |
| <a name="input_wg_restart_lambda_timeout_sec"></a> [wg\_restart\_lambda\_timeout\_sec](#input\_wg\_restart\_lambda\_timeout\_sec) | Timeout for Lambda which restarts Wireguard instances when configuration changes occured | `number` | `300` | no |

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
[]: # (END_TF_DOCS)      

### Contribute
Any reasonable pull requests are always welcomed. All PRs are subject to automated checks, so please make sure that your changes pass all configured [pre-commit](https://pre-commit.com/) hooks.
If you found a bug or need support of any kind, please start a new conversation in `Issues` section. 

### License
The code is licensed under GNU GPL [license](./LICENSE.md).
