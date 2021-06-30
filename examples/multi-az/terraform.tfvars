# Wireguard
wg_allow_connections_from_subnets = ["0.0.0.0/0"]
wg_peers = {
  yurii = {
    public_key      = ""
    peer_ip         = "10.0.44.2/32"
    allowed_subnets = ["0.0.0.0/0"]
    isolated        = true
  }
  alex = {
    public_key      = ""
    peer_ip         = "10.0.44.3/32"
    allowed_subnets = ["10.0.44.0/24"]
    isolated        = true
  }
}

# VPC
vpc_cidr            = "10.0.0.0/16"
az_count            = 2
vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

# EC2
ec2_ssh_public_key = "[YOUR SSH PUBLIC KEY]"

# S3
s3_bucket_name_prefix = "[S3 BUCKET NAME PREFIX]"

# Route53
dns_zone_name = "[YOUR ROUTE53 DNS ZONE NAME WITHOUT TRAILING DOT — example.com]"

# Common
tags = {
  Managed-by = "Terraform"
}
