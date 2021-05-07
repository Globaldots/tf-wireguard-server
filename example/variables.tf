variable "vpc_cidr" {
  type        = string
  description = "AWS desired VPC CIDR"
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "VPC availability zones"
}

variable "wg_listen_ports" {
  type        = list(string)
  description = "Wireguard listen ports"
  default     = ["51820", "4500", "53"]
}

variable "wg_peers" {
  type        = map(object({ public_key = string, allowed_ips = string }))
  description = "Wireguard clients (peers) configuration"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "VPC private subnet CIDRs"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "VPC public subnet CIDRs"
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

variable "enable_termination_protection" {
  type        = bool
  description = "Enable termination protection for resources"
}

variable "wg_allow_connections_from_subnets" {
  type        = list(string)
  description = "Restrict Wireguard server availability to defined subnets"
}

variable "dns_zone_name" {
  type        = string
  description = "Route53 DNS zone name for Wireguard server endpoint"
}
