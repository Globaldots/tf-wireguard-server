# Get list of available AZs for current region
data "aws_availability_zones" "main-a" {
  provider = aws.region_a
  state    = "available"
}

data "aws_availability_zones" "main-b" {
  provider = aws.region_b
  state    = "available"
}

# Generate private/public key pair for Wireguard server
resource "wireguard_asymmetric_key" "wg_key_pair" {}

# Generate private/public key pairs for Wireguard clients
resource "wireguard_asymmetric_key" "wg_key_pair_clients" {
  for_each = toset(
    [
      for k, v in var.wg_peers : k
      if try(v.public_key, "") == ""
    ]
  )
}

locals {
  wg_peers = {
    for k, v in var.wg_peers :
    k => merge(
      v,
      try({ public_key = wireguard_asymmetric_key.wg_key_pair_clients[k].public_key }, {})
    )
  }
}

# Random pet name generator
resource "random_pet" "main" {
  keepers = {
    wg_private_key = wireguard_asymmetric_key.wg_key_pair.private_key
  }
}

# Create a VPC
module "vpc-a" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"
  providers = {
    aws = aws.region_a
  }

  name               = "wireguard-${random_pet.main.id}-a"
  cidr               = var.region_a_vpc_cidr
  azs                = slice(data.aws_availability_zones.main-a.names, 0, var.region_a_az_count)
  private_subnets    = var.region_a_vpc_private_subnets
  public_subnets     = var.region_a_vpc_public_subnets
  enable_nat_gateway = true

  tags = var.tags
}

module "vpc-b" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"
  providers = {
    aws = aws.region_b
  }

  name               = "wireguard-${random_pet.main.id}-b"
  cidr               = var.region_b_vpc_cidr
  azs                = slice(data.aws_availability_zones.main-b.names, 0, var.region_b_az_count)
  private_subnets    = var.region_b_vpc_private_subnets
  public_subnets     = var.region_b_vpc_public_subnets
  enable_nat_gateway = true
  tags               = var.tags
}

# Add your key for SSH access to VM
resource "aws_key_pair" "main-a" {
  provider   = aws.region_a
  key_name   = "deployer-one-${random_pet.main.id}"
  public_key = var.ec2_ssh_public_key
  tags       = var.tags
}

resource "aws_key_pair" "main-b" {
  provider   = aws.region_b
  key_name   = "deployer-one-${random_pet.main.id}"
  public_key = var.ec2_ssh_public_key
  tags       = var.tags
}

# Envoke the Wireguard module
module "wg-a" {
  source = "../../"
  providers = {
    aws = aws.region_a
  }

  vpc_id                            = module.vpc-a.vpc_id
  public_subnet_cidrs               = module.vpc-a.public_subnets_cidr_blocks
  private_subnet_cidrs              = module.vpc-a.private_subnets_cidr_blocks
  ssh_keypair_name                  = aws_key_pair.main-a.key_name
  name_suffix                       = random_pet.main.id
  s3_bucket_name_prefix             = var.region_a_s3_bucket_name_prefix
  wg_private_key                    = wireguard_asymmetric_key.wg_key_pair.private_key
  wg_public_key                     = wireguard_asymmetric_key.wg_key_pair.public_key
  wg_allow_connections_from_subnets = var.wg_allow_connections_from_subnets
  wg_peers                          = local.wg_peers
  tags                              = var.tags
}

module "wg-b" {
  source = "../../"
  providers = {
    aws = aws.region_b
  }

  vpc_id                            = module.vpc-b.vpc_id
  public_subnet_cidrs               = module.vpc-b.public_subnets_cidr_blocks
  private_subnet_cidrs              = module.vpc-b.private_subnets_cidr_blocks
  ssh_keypair_name                  = aws_key_pair.main-b.key_name
  name_suffix                       = random_pet.main.id
  s3_bucket_name_prefix             = var.region_b_s3_bucket_name_prefix
  wg_private_key                    = wireguard_asymmetric_key.wg_key_pair.private_key
  wg_public_key                     = wireguard_asymmetric_key.wg_key_pair.public_key
  wg_allow_connections_from_subnets = var.wg_allow_connections_from_subnets
  wg_peers                          = local.wg_peers
  tags                              = var.tags
}

resource "aws_route53_record" "main" {
  count          = length(local.region_endpoints)
  zone_id        = data.aws_route53_zone.main.zone_id
  name           = "wireguard-${random_pet.main.id}"
  type           = "A"
  set_identifier = local.region_endpoints[count.index].dns_name

  alias {
    name                   = local.region_endpoints[count.index].dns_name
    zone_id                = local.region_endpoints[count.index].zone_id
    evaluate_target_health = true
  }

  dynamic "weighted_routing_policy" {
    for_each = lower(trim(var.load_balancing_policy, " ")) == "weighted" ? [true] : []
    content {
      weight = 1
    }
  }

  dynamic "latency_routing_policy" {
    for_each = lower(trim(var.load_balancing_policy, " ")) == "latency" ? [true] : []
    content {
      region = local.region_endpoints[count.index].region
    }
  }
}
