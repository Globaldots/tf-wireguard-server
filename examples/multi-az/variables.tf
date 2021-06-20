variable "vpc_cidr" {
  type        = string
  description = "AWS desired VPC CIDR"
}

variable "az_count" {
  type        = string
  description = "Number of availability zones to create VPC subnets in"
}

variable "wg_peers" {
  type        = map(object({ public_key = string, peer_ip = string, allowed_subnets = list(string), isolated = bool }))
  description = "Wireguard clients (peers) configuration. `Public_key` is optional — will be automatically generated if empty. `Peer_ip` — desired client IP-address or subnet in CIDR notation within Wireguard network (must be within `wg_cidr` range). `Allowed_subnets` — controls what subnets peer will be able to access through Wireguard network (for bounce server mode set to `0.0.0.0/0`). `Isolated` — if `true` peer won't be able to access other Wireguard peers."
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "VPC private subnets CIDR to create EC2 instances in. AZs of public & private subnets must match"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "VPC public subnets CIDR to create NLB in. Multiple subnets are used for HA. AZs of public & private subnets must match"
}

variable "ec2_ssh_public_key" {
  type        = string
  description = "EC2 SSH public key"
}

variable "s3_bucket_name_prefix" {
  type        = string
  description = "Prefix to be added to S3 bucket name"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to all resources"
  default     = {}
}

variable "wg_allow_connections_from_subnets" {
  type        = list(string)
  description = "Allow inbound connections to Wireguard server from these networks. To allow all networks set to `0.0.0.0/0`"
}

variable "dns_zone_name" {
  type        = string
  description = "Route53 DNS zone name for Wireguard server endpoint. If not set, AWS LB DNS record is used"
  default     = ""
}
