###############################################################################
### COMMON ####################################################################
###############################################################################

# Wireguard
wg_allow_connections_from_subnets = ["0.0.0.0/0"]
wg_peers = {
  user-1 = {
    public_key      = ""
    peer_ip         = "10.0.44.2/32"
    allowed_subnets = ["0.0.0.0/0"]
    isolated        = true
  }
  user-2 = {
    public_key      = ""
    peer_ip         = "10.0.44.3/32"
    allowed_subnets = ["0.0.0.0/0"]
    isolated        = true
  }
}

# Route53
dns_zone_name = "[YOUR ROUTE53 DNS ZONE NAME WITHOUT TRAILING DOT — example.com]"

# EC2
ec2_ssh_public_key = "[YOUR SSH PUBLIC KEY]"

# All
tags = {
  Managed-by = "Terraform"
}

###############################################################################
### REGION A ##################################################################
###############################################################################

# VPC
region_a_vpc_cidr            = "10.0.0.0/16"
region_a_az_count            = 2
region_a_vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
region_a_vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

# S3
region_a_s3_bucket_name_prefix = "[S3 BUCKET NAME PREFIX]"

###############################################################################
### REGION B ##################################################################
###############################################################################

region_b = "us-east-2"

# VPC
region_b_vpc_cidr            = "10.10.0.0/16"
region_b_az_count            = 2
region_b_vpc_private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
region_b_vpc_public_subnets  = ["10.10.101.0/24", "10.10.102.0/24"]

# S3
region_b_s3_bucket_name_prefix = "[S3 BUCKET NAME PREFIX]"
