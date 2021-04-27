variable "aws_region" {
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "wireguard-server"
}

variable "ami_name_filter" {
  type        = string
  description = "The name filter to use in data.aws_ami"
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_owner" {
  default     = "099720109477" # Canonical
  description = "The AWS account ID of the AMI owner"
}

variable "instance_type" {
  type    = string
  default = "t3a.micro"
}

variable "subnet_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ssm_secret_prefix" {
  default = ""
}

variable "key_name" {
  default = ""
}

variable "wg_address" {
  default = "10.0.44.1/24"
}

variable "wg_cidr" {
  default = "10.0.44.0/24"
}

variable "dns_server" {
  default = "1.1.1.1"
}

variable "wg_listen_port" {
  default = "51820"
}

variable "wg_private_key" {
  type        = string
  description = "WireGuard Server Private Key"
  sensitive   = true
}

variable "wg_public_key" {
  type        = string
  description = "WireGuard Server Public Key"
  sensitive   = true
}

variable "wg_peers" {
  type    = map(object({ public_key = string, allowed_ips = string }))
  default = {}
}
