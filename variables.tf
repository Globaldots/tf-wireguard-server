variable "ami_name_filter" {
  type        = string
  description = "Name filter to use in data.aws_ami"
  #TODO: should we lock AMI version?
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_owner" {
  type        = string
  default     = "099720109477" # Canonical
  description = "AMI owner AWS account ID"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3a.micro"
}

variable "ec2_iam_policy_names" {
  type        = list(string)
  description = "Additional IAM policies to assign to EC2 instances through instance profile"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "VPC subnet CIDRs to create resources in (multiple subnets are used for HA)"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to all resources"
  default     = {}
}

variable "ssh_keypair_name" {
  type        = string
  description = "EC2 SSH keypair name"
}

variable "wg_cidr" {
  type        = string
  description = "Wireguard network subnet CIDR"
  default     = "10.0.44.0/24"
}

variable "wg_listen_ports" {
  type        = list(string)
  description = "Wireguard listen ports"
  default     = ["51820", "4500", "53"]
}

variable "wg_private_key" {
  type        = string
  description = "WireGuard server private Key"
  sensitive   = true
}

variable "wg_dns_server" {
  type        = string
  description = "DNS server for Wireguard network"
  default     = "8.8.8.8"
}

variable "wg_peers" {
  type        = map(object({ public_key = string, allowed_ips = string }))
  description = "Wireguard clients (peers) configuration"
  default     = {}
}

variable "wg_mtu" {
  type        = number
  description = "MTU value for Wireguard network"
  default     = "1420"
}

variable "name_suffix" {
  type        = string
  description = "Suffix to be added to all resources"
}

variable "s3_bucket_name_prefix" {
  type        = string
  description = "Prefix to be added to S3 bucket name"
}

variable "enable_termination_protection" {
  type        = bool
  description = "Enable termination protection for resources"
  default     = true
}

variable "wg_ha_instance_min_count" {
  type        = number
  description = "Minimum number of Wiregard instances (HA configuration)"
  default     = 2
}

variable "wg_ha_instance_max_count" {
  type        = number
  description = "Maximum number of Wiregard instances (HA configuration)"
  default     = 2
}

variable "wg_ha_instance_desired_count" {
  type        = number
  description = "Desired number of Wiregard instances (HA configuration)"
  default     = 2
}

variable "wg_allow_connections_from_subnets" {
  type        = list(string)
  description = "Restrict Wireguard server availability to defined subnets"
}

variable "dns_zone_name" {
  type        = string
  description = "Route53 DNS zone name for Wireguard server endpoint"
}