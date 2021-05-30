## How to
This example supports both `terraform` and `terragrunt`

### Run terragrunt
```shell
cd examples/
export AWS_REGION=<your region>
aws-vault exec $AWS_PROFILE --no-session  -- terragrunt init
aws-vault exec $AWS_PROFILE --no-session  -- terragrunt plan
aws-vault exec $AWS_PROFILE --no-session  -- terragrunt apply
```

### Get WG server's private/public keys
```shell
cd examples/
aws-vault exec $AWS_PROFILE --no-session  -- terragrunt output wireguard_keys
```

### Run `terraform` in case you don't want to use `terragrunt`
```shell
cd examples/
terraform plan -var-file terraform.tfvars
```

### Generate pair private/public keys for the client
```shell
umask 077 ; wg genkey > privatekey ; wg pubkey < privatekey > publickey
```

### Add your `publickey` and `allowed_ips`  to the `terraform.tfvars` file
```shell
wg_peers = {
  myuser1 = {
    public_key  = "<public key for myuser1>"
    allowed_ips = "10.0.44.2/32"
  }
  myuser2 = {
    public_key  = "<public key for myuser2>"
    allowed_ips = "10.0.44.3/32"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.15.0 |
| aws | ~> 3.37.0 |
| random | ~> 3.1.0 |
| wireguard | 0.1.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| az\_count | Number of availability zones to create VPC subnets in | `string` | n/a | yes |
| dns\_zone\_name | Route53 DNS zone name for Wireguard server endpoint | `string` | n/a | yes |
| ec2\_ssh\_public\_key | EC2 SSH public key | `string` | n/a | yes |
| enable\_termination\_protection | Enable termination protection for resources | `bool` | n/a | yes |
| s3\_bucket\_name\_prefix | Prefix to be added to S3 bucket name | `string` | n/a | yes |
| vpc\_cidr | AWS desired VPC CIDR | `string` | n/a | yes |
| vpc\_private\_subnets | VPC private subnet CIDRs | `list(string)` | n/a | yes |
| vpc\_public\_subnets | VPC public subnet CIDRs | `list(string)` | n/a | yes |
| wg\_allow\_connections\_from\_subnets | Restrict Wireguard server availability to defined subnets | `list(string)` | n/a | yes |
| wg\_peers | Wireguard clients (peers) configuration | `map(object({ public_key = string, allowed_ips = string }))` | n/a | yes |
| tags | Tags to assign to all resources | `map(string)` | `{}` | no |
| wg\_listen\_ports | Wireguard listen ports | `list(string)` | <pre>[<br>  "51820",<br>  "4500",<br>  "53"<br>]</pre> | no |

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
| wireguard\_keys | Wireguard public & private keys |
| wireguard\_server\_endpoints | Wireguard server endpoints |
| wireguard\_server\_host | Wireguard server host |
| wireguard\_server\_name | Wireguard server name |
| wireguard\_server\_ports | Wireguard server ports |
