## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.37.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1.0 |
| <a name="requirement_wireguard"></a> [wireguard](#requirement\_wireguard) | 0.1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.37.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1.0 |
| <a name="provider_wireguard"></a> [wireguard](#provider\_wireguard) | 0.1.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 2.78.0 |
| <a name="module_wg"></a> [wg](#module\_wg) | ../ |  |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [random_pet.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [wireguard_asymmetric_key.wg_key_pair](https://registry.terraform.io/providers/OJFord/wireguard/0.1.3/docs/resources/asymmetric_key) | resource |
| [aws_availability_zones.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Number of availability zones to create VPC subnets in | `string` | n/a | yes |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Route53 DNS zone name for Wireguard server endpoint | `string` | n/a | yes |
| <a name="input_ec2_ssh_public_key"></a> [ec2\_ssh\_public\_key](#input\_ec2\_ssh\_public\_key) | EC2 SSH public key | `string` | n/a | yes |
| <a name="input_enable_termination_protection"></a> [enable\_termination\_protection](#input\_enable\_termination\_protection) | Enable termination protection for resources | `bool` | n/a | yes |
| <a name="input_s3_bucket_name_prefix"></a> [s3\_bucket\_name\_prefix](#input\_s3\_bucket\_name\_prefix) | Prefix to be added to S3 bucket name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | AWS desired VPC CIDR | `string` | n/a | yes |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | VPC private subnet CIDRs | `list(string)` | n/a | yes |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | VPC public subnet CIDRs | `list(string)` | n/a | yes |
| <a name="input_wg_allow_connections_from_subnets"></a> [wg\_allow\_connections\_from\_subnets](#input\_wg\_allow\_connections\_from\_subnets) | Restrict Wireguard server availability to defined subnets | `list(string)` | n/a | yes |
| <a name="input_wg_listen_ports"></a> [wg\_listen\_ports](#input\_wg\_listen\_ports) | Wireguard listen ports | `list(string)` | <pre>[<br>  "51820",<br>  "4500",<br>  "53"<br>]</pre> | no |
| <a name="input_wg_peers"></a> [wg\_peers](#input\_wg\_peers) | Wireguard clients (peers) configuration | `map(object({ public_key = string, allowed_ips = string }))` | n/a | yes |

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
| <a name="output_wireguard_keys"></a> [wireguard\_keys](#output\_wireguard\_keys) | Wireguard public & private keys |
| <a name="output_wireguard_server_endpoints"></a> [wireguard\_server\_endpoints](#output\_wireguard\_server\_endpoints) | Wireguard server endpoints |
| <a name="output_wireguard_server_host"></a> [wireguard\_server\_host](#output\_wireguard\_server\_host) | Wireguard server host |
| <a name="output_wireguard_server_name"></a> [wireguard\_server\_name](#output\_wireguard\_server\_name) | Wireguard server name |
| <a name="output_wireguard_server_ports"></a> [wireguard\_server\_ports](#output\_wireguard\_server\_ports) | Wireguard server ports |
