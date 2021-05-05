## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.15.0 |
| aws | ~> 3.37.0 |
| random | ~> 3.1.0 |
| wireguard | 0.1.3 |

## Providers

| Name | Version |
|------|---------|
| random | ~> 3.1.0 |
| wireguard | 0.1.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ec2\_ssh\_public\_key | EC2 SSH public key | `string` | n/a | yes |
| s3\_bucket\_name\_prefix | Prefix to be added to S3 bucket name | `string` | n/a | yes |
| tags | Tags to assign to all resources | `map(string)` | `{}` | no |
| vpc\_availability\_zones | VPC availability zones | `list(string)` | n/a | yes |
| vpc\_cidr | AWS desired VPC CIDR | `string` | n/a | yes |
| vpc\_private\_subnets | VPC private subnet CIDRs | `list(string)` | n/a | yes |
| vpc\_public\_subnets | VPC public subnet CIDRs | `list(string)` | n/a | yes |
| wg\_listen\_port | Wireguard listen port | `string` | n/a | yes |

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
| wireguard\_keys | Wireguard public & private keys |
| wireguard\_server\_endpoint | Wireguard server endpoint |
| wireguard\_server\_ip | Wireguard server IP-address |
| wireguard\_server\_name | Wireguard server name |
| wireguard\_server\_port | Wireguard server port |

