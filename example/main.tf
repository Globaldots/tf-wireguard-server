# Generate private/public key pair for Wireguard server
resource "wireguard_asymmetric_key" "wg_key_pair" {}

# Create a VPC
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

# Create a security group
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

# Add your key for SSH access to VM
module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "1.0.0"

  key_name   = "deployer-one"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDyQd3GtSqa9baNUZyrTN8pWBxV5wHEUoHxeE1z5Yi66szMbT1tRjt/vOMLpHFzyb3Zbn0mdDGvcyrJocS0lP00ZQKTJi5e5WnVPaeGKU9nAy09aV33NsmuIi3y4jNExft4KXBUM6dfMWVu4oBWPL4kCuHqtupzYmlnoGHheq2xbaoqAVQAEJs3ulmKbXxoqzIua5J0A1qo60UYQrLqjlVOV1qLXMcpJtshcGeDb9myZAttamNmFM5AMLZProMY8A3yO/V3aQtCoBzl4xdtlCEQpzlBJOr85lbGTyEh63NqEyW980D65AJHXuwrjJq9UJ8jNcX8VIyC9U6kiQsVwZAZFr9Q6h0E5z/l283yk3vdNTOJu6WR3Hsu7YCKU2+T7QcP31Qdc8bCwbOOF5UqCDcvDn1P+ip5o9j+sGv/u3k6bzIQWo8QKJOaoBiTKzhnSUfJhLuPWPNFylx69TgDaCd20ejwm4DSre+WSitPhS86tdCN2zo/6YupDArvzvwC4Ll9PeVNz9a8wE2kTOfcPd8pkb8rNRSiDyPTYnZ/iYlQre4z/w+NNH7ZVaVzCytsinWQer0jnSV1ogxm8ZTWnkLckt/demAOUzT/y6dhjrjcaxhcpm84WohCHxcMWudSDzsuS/qDxXevjLKp2YP/QzmW8quGu75iHYkq1pgkYRyJ4Q== alex@Alexs-MacBook-Pro.local"
}

# Envoke the Wireguard module
module "wg" {
  source = "../"

  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.sg.this_security_group_id]
  //  availability_zones     = module.vpc.azs
  ssm_parameter  = module.wg.ssm_parameter
  wg_private_key = wireguard_asymmetric_key.wg_key_pair.private_key
  wg_public_key  = wireguard_asymmetric_key.wg_key_pair.public_key
  aws_region     = "eu-central-1"
  key_name       = module.key_pair.key_pair_key_name

  wg_peers = {
    yurii = {
      public_key  = "dRWcZBv2++23GZ0DdoFLrXvGch4lcZ2Fj7yeaSAUB2I="
      allowed_ips = "10.0.44.2/32"
    }
    alex = {
      public_key  = "D9HA+Qhe/kR0nwVxId2vNSuP0SozOh3umC5PKvL3b1Y="
      allowed_ips = "10.0.44.3/32"
    }
  }
}

# Remote Wireguard restart (less recommended way)
resource "null_resource" "remote_exec" {

  triggers = {
    key = "${uuid()}"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = var.username
      host        = module.wg.wireguard_server_ip
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "sudo wg-quick down wg0",
      "sudo wg-quick up wg0"
    ]
  }

  depends_on = [
    module.wg
  ]
}
