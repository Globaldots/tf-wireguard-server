# Get list of available AZs for current region
data "aws_availability_zones" "main" {
  state = "available"
}

# Generate private/public key pair for Wireguard server
resource "wireguard_asymmetric_key" "wg_key_pair" {}

# Random pet name generator
resource "random_pet" "main" {
  keepers = {
    wg_private_key = wireguard_asymmetric_key.wg_key_pair.private_key
  }
}

# Create a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name = "Test-VPC-for-WireGuard-${random_pet.main.id}"

  cidr               = var.vpc_cidr
  azs                = slice(data.aws_availability_zones.main.names, 0, var.az_count)
  private_subnets    = var.vpc_private_subnets
  public_subnets     = var.vpc_public_subnets
  enable_nat_gateway = true

  tags = var.tags
}

# Add your key for SSH access to VM
resource "aws_key_pair" "main" {
  key_name   = "deployer-one-${random_pet.main.id}"
  public_key = var.ec2_ssh_public_key
  tags       = var.tags
}

# Envoke the Wireguard module
module "wg" {
  source = "../../"

  vpc_id                            = module.vpc.vpc_id
  public_subnet_cidrs               = module.vpc.public_subnets_cidr_blocks
  private_subnet_cidrs              = module.vpc.private_subnets_cidr_blocks
  ssh_keypair_name                  = aws_key_pair.main.key_name
  name_suffix                       = random_pet.main.id
  s3_bucket_name_prefix             = var.s3_bucket_name_prefix
  wg_private_key                    = wireguard_asymmetric_key.wg_key_pair.private_key
  wg_public_key                     = wireguard_asymmetric_key.wg_key_pair.public_key
  wg_allow_connections_from_subnets = var.wg_allow_connections_from_subnets
  dns_zone_name                     = var.dns_zone_name
  wg_peers                          = var.wg_peers
  tags                              = var.tags
}
