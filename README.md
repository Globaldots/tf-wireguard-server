## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.15.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_name\_filter | The name filter to use in data.aws\_ami | `string` | `"ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"` | no |
| ami\_owner | The AWS account ID of the AMI owner | `string` | `"099720109477"` | no |
| aws\_region | n/a | `string` | `"us-east-1"` | no |
| dns\_server | n/a | `string` | `"1.1.1.1"` | no |
| instance\_type | n/a | `string` | `"t3a.micro"` | no |
| key\_name | n/a | `string` | `""` | no |
| name\_prefix | n/a | `string` | `"wireguard-server"` | no |
| ssm\_parameter | n/a | `string` | `""` | no |
| ssm\_secret\_prefix | n/a | `string` | `""` | no |
| subnet\_id | n/a | `string` | n/a | yes |
| tags | n/a | `map(string)` | `{}` | no |
| vpc\_security\_group\_ids | n/a | `list(string)` | n/a | yes |
| wg\_address | n/a | `string` | `"10.0.44.1/24"` | no |
| wg\_cidr | n/a | `string` | `"10.0.44.0/24"` | no |
| wg\_listen\_port | n/a | `string` | `"51820"` | no |
| wg\_peers | n/a | `map(object({ public_key = string, allowed_ips = string }))` | `{}` | no |
| wg\_private\_key | WireGuard Server Private Key | `string` | n/a | yes |
| wg\_public\_key | WireGuard Server Public Key | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ssm\_parameter | n/a |
| wireguard\_server\_endpoint | n/a |
| wireguard\_server\_ip | n/a |
| wireguard\_server\_port | n/a |

