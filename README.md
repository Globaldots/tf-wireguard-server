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
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_name\_filter | Name filter to use in data.aws\_ami | `string` | `"ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"` | no |
| ami\_owner | AMI owner AWS account ID | `string` | `"099720109477"` | no |
| ec2\_instance\_type | EC2 instance type | `string` | `"t3a.micro"` | no |
| name\_suffix | Suffix to be added to all resources | `string` | n/a | yes |
| s3\_bucket\_name\_prefix | Prefix to be added to S3 bucket name | `string` | n/a | yes |
| security\_group\_ids | VPC (EC2) security group IDs | `list(string)` | n/a | yes |
| ssh\_keypair\_name | EC2 SSH keypair name | `string` | n/a | yes |
| subnet\_cidr | VPC subnet CIDR to create resources in | `string` | n/a | yes |
| tags | Tags to assign to all resources | `map(string)` | `{}` | no |
| vpc\_id | AWS VPC ID | `string` | n/a | yes |
| wg\_cidr | Wireguard network subnet CIDR | `string` | `"10.0.44.0/24"` | no |
| wg\_dns\_server | DNS server for Wireguard network | `string` | `"8.8.8.8"` | no |
| wg\_listen\_port | Wireguard listen port | `string` | `"51820"` | no |
| wg\_peers | Wireguard clients (peers) configuration | `map(object({ public_key = string, allowed_ips = string }))` | `{}` | no |
| wg\_private\_key | WireGuard server private Key | `string` | n/a | yes |

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
| s3\_bucket\_arn | Wireguard configuration S3 bucket ARN |
| s3\_bucket\_name | Wireguard configuration S3 bucket name |
| sqs\_queue\_arn | SQS queue for S3 notifications ARN |
| sqs\_queue\_dead\_letter\_arn | SQS dead letter queue for S3 notifications ARN |
| sqs\_queue\_dead\_letter\_id | SQS dead letter queue for S3 notifications ID |
| sqs\_queue\_id | SQS queue for S3 notifications ID |
| wireguard\_server\_endpoint | Wireguard server endpoint |
| wireguard\_server\_ip | Wireguard server IP-address |
| wireguard\_server\_name | Wireguard server name |
| wireguard\_server\_port | Wireguard server port |

