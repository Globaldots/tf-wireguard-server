## tf-wireguard-server  
This is the main code to deploy Wireguard VPN Server on top of AWS Amazon EC2, which includes
(ASG, ENI, EIP, launch template, and many more).

Please check folder example/ to see how this module can be provisioned

Please, find deployment instruction in README.md file of repository root.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| archive | n/a |
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudwatch\_alerts\_emails | Email addresses to get monitoring alerts from CloudWatch | `list(string)` | `[]` | no |
| cloudwatch\_alerts\_phone\_numbers | Phone numbers to get monitoring alerts from CloudWatch | `list(string)` | `[]` | no |
| dns\_zone\_name | Route53 DNS zone name for Wireguard server endpoint | `string` | n/a | yes |
| ec2\_iam\_policy\_names | Additional IAM policies to assign to EC2 instances through instance profile | `list(string)` | `[]` | no |
| ec2\_instance\_type | EC2 instance type | `string` | `"t3a.micro"` | no |
| enable\_termination\_protection | Enable termination protection for resources | `bool` | `true` | no |
| name\_suffix | Suffix to be added to all resources | `string` | n/a | yes |
| private\_subnet\_cidrs | VPC private subnet CIDRs to create EC2 instances in (AZs of public & private subnets should match) | `list(string)` | n/a | yes |
| public\_subnet\_cidrs | VPC public subnet CIDRs to create NLB in (multiple subnets are used for HA, AZs of public & private subnets should match) | `list(string)` | n/a | yes |
| s3\_bucket\_name\_prefix | Prefix to be added to S3 bucket name | `string` | n/a | yes |
| ssh\_keypair\_name | EC2 SSH keypair name | `string` | n/a | yes |
| tags | Tags to assign to all resources | `map(string)` | `{}` | no |
| vpc\_id | AWS VPC ID | `string` | n/a | yes |
| wg\_allow\_connections\_from\_subnets | Restrict Wireguard server availability to defined subnets | `list(string)` | n/a | yes |
| wg\_cidr | Wireguard network subnet CIDR | `string` | `"10.0.44.0/24"` | no |
| wg\_dns\_server | DNS server for Wireguard network | `string` | `"8.8.8.8"` | no |
| wg\_ha\_instance\_desired\_count | Desired number of Wiregard instances (HA configuration) | `number` | `2` | no |
| wg\_ha\_instance\_max\_count | Maximum number of Wiregard instances (HA configuration) | `number` | `2` | no |
| wg\_ha\_instance\_min\_count | Minimum number of Wiregard instances (HA configuration) | `number` | `2` | no |
| wg\_listen\_ports | Wireguard listen ports | `list(string)` | <pre>[<br>  "51820",<br>  "4500",<br>  "53"<br>]</pre> | no |
| wg\_mtu | MTU value for Wireguard network | `number` | `"1420"` | no |
| wg\_peers | Wireguard clients (peers) configuration | `map(object({ public_key = string, allowed_ips = string }))` | `{}` | no |
| wg\_private\_key | WireGuard server private key | `string` | n/a | yes |
| wg\_public\_key | WireGuard server public key | `string` | n/a | yes |
| wg\_restart\_lambda\_max\_errors\_count | Lambda which restarts Wireguard instances when configuration changes detected will stop execution if number of errors exceed this value | `number` | `0` | no |
| wg\_restart\_lambda\_timeout\_sec | Timeout for Lambda which restarts Wireguard instances when configuration changes occured | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_arn | EC2 autoscaling group ARN |
| autoscaling\_group\_name | EC2 autoscaling group name |
| iam\_instance\_profile\_arn | ARN of IAM instance profile to access S3 bucket |
| iam\_instance\_profile\_id | ID of IAM instance profile to access S3 bucket |
| iam\_role\_arn | ARN of IAM role to access S3 bucket |
| iam\_role\_name | Name of IAM role to access S3 bucket |
| launch\_template\_arn | EC2 launch template ARN |
| launch\_template\_id | EC2 launch template ID |
| lb\_arn | Load balancer ARN |
| lb\_dns\_name | Load balancer DNS name |
| s3\_bucket\_access\_logs\_arn | Load balancer access logs S3 bucket ARN |
| s3\_bucket\_access\_logs\_name | Load balancer access logs S3 bucket name |
| s3\_bucket\_arn | Wireguard configuration S3 bucket ARN |
| s3\_bucket\_name | Wireguard configuration S3 bucket name |
| sqs\_queue\_arn | SQS queue for S3 notifications ARN |
| sqs\_queue\_dead\_letter\_arn | SQS dead letter queue for S3 notifications ARN |
| sqs\_queue\_dead\_letter\_id | SQS dead letter queue for S3 notifications ID |
| sqs\_queue\_id | SQS queue for S3 notifications ID |
| wireguard\_client\_configs | Example configuration files for Wireguard clients |
| wireguard\_server\_endpoints | Wireguard server endpoints |
| wireguard\_server\_host | Wireguard server host |
| wireguard\_server\_name | Wireguard server name |
| wireguard\_server\_ports | Wireguard server ports |

