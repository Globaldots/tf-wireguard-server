variable "ami_name_filter" {
  type        = string
  description = "Name filter to use in data.aws_ami"
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_owner" {
  default     = "099720109477" # Canonical
  description = "AMI owner AWS account ID"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3a.micro"
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC ID"
}

variable "subnet_cidr" {
  type        = string
  description = "VPC subnet CIDR to create resources in"
}

variable "security_group_ids" {
  type        = list(string)
  description = "VPC (EC2) security group IDs"
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

variable "wg_listen_port" {
  type        = string
  description = "Wireguard listen port"
  default     = "51820"
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

variable "name_suffix" {
  type        = string
  description = "Suffix to be added to all resources"
}

variable "s3_bucket_name_prefix" {
  type        = string
  description = "Prefix to be added to S3 bucket name"
}
