###############################################################################
### COMMON ####################################################################
###############################################################################

# Wireguard
wg_allow_connections_from_subnets = ["0.0.0.0/0"]
wg_peers = {
  user-1 = {
    public_key      = "U/2FptGTCVaY3laN49blUv1zf8KcD8oVALzQ0j/HSzY="
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
dns_zone_name = "nationalcdn.ru"

# EC2
ec2_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBjZ/tOu3UdUT3Q8jDAivKM+tW0PnHH5Jc+8NedDk7cTZzfIPZMLxf4iF633HFwjwBmadNDmcoAaGhu8s+WjFIUiWcq9vvHmS/DXexEeoRthEXjFgl6x2vNg+yGADdDKg0cdeMMBqVxqKbFpiaj+Bhkup0WSQ+vKkwhkknxwTFV8ixLWer1liE1jDhmnjgg+bz0FMfh1U0qmLcL9Khktu7P4D1Zz9+0aOAx1UigXvvlQ+k4WF5GMG4UTSKw2J0i8Ayzojm7ZwVZ0Km/iTg19emPtBizOFxcx7OvqSnz4ZIKeoss5Bimd2vVOvZqwJEC2LCVJbdAIwxxQTkWk2i5mduKBnZ+ukuf7ov8Vt5rVkOmkZJvStGSDZmVwRghvzSrS9Cp8bLeiLFwIr7u5QmxyFn8hdMgiNoKUFXJKopLYRLN/X4qGa03ogLeQVFwLmP9GnjFI3WOAAr8MW02SKb82cqzXLNPeZBIEAkSPGHLesczzFkyHSG/xAkStzXsnQfGy8= wireguard@test"

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
region_a_s3_bucket_name_prefix = "awesome-wg-a"

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
region_b_s3_bucket_name_prefix = "awesome-wg-b"
