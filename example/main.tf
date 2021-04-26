terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.37.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    wireguard = {
      source  = "OJFord/wireguard"
      version = "0.1.3"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "wireguard" {}

resource "wireguard_asymmetric_key" "wg_key_pair" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name = "Test-VPC-for-WireGuard"

  cidr = "10.0.0.0/16"

  azs = [
    "eu-central-1a",
    "eu-central-1b",
  ]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  //  enable_nat_gateway = false
  //  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Description = "Test VPC for WireGuard"
  }
}

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.18.0"

  name        = "WireGuard"
  description = "Security group for WireGuard"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 51820
      to_port     = 51820
      protocol    = "udp"
      description = "WireGuard"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      cidr_blocks = "0.0.0.0/0"
      protocol    = "-1"
    }
  ]

}

module "wg" {
  source = "../"

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.sg.this_security_group_id]
  //  availability_zones     = module.vpc.azs
  wg_private_key = wireguard_asymmetric_key.wg_key_pair.private_key
  wg_public_key  = wireguard_asymmetric_key.wg_key_pair.public_key
  aws_region = "eu-central-1"

  wg_peers = {
    yurii = {
      public_key  = "dRWcZBv2++23GZ0DdoFLrXvGch4lcZ2Fj7yeaSAUB2I="
      allowed_ips = "10.0.44.2/32"
    }
  }
}
