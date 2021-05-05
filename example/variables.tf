variable "vpc_cidr" {
  type        = string
  description = "AWS desired VPC CIDR"
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "VPC availability zones"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "VPC private subnet CIDRs"
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "VPC public subnet CIDRs"
}

variable "wg_listen_port" {
  type        = string
  description = "Wireguard listen port"
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



