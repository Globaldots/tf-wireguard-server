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

  cidr            = var.vpc_cidr
  azs             = var.vpc_availability_zones
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  tags = var.tags
}

# Add your key for SSH access to VM
module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "1.0.0"

  key_name   = "deployer-one-${random_pet.main.id}"
  public_key = var.ec2_ssh_public_key
  tags       = var.tags
}

# Envoke the Wireguard module
module "wg" {
  source = "../"

  vpc_id                            = module.vpc.vpc_id
  subnet_cidrs                      = module.vpc.private_subnets_cidr_blocks
  ssh_keypair_name                  = module.key_pair.key_pair_key_name
  name_suffix                       = random_pet.main.id
  s3_bucket_name_prefix             = var.s3_bucket_name_prefix
  wg_private_key                    = wireguard_asymmetric_key.wg_key_pair.private_key
  wg_listen_ports                   = var.wg_listen_ports
  wg_allow_connections_from_subnets = var.wg_allow_connections_from_subnets
  dns_zone_name                     = var.dns_zone_name

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
  tags = var.tags
}

# Remote Wireguard restart (less recommended way)
# resource "null_resource" "remote_exec" {

#   triggers = {
#     key = "${uuid()}"
#   }

#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = var.username
#       host        = module.wg.wireguard_server_ip
#       private_key = file("~/.ssh/id_rsa")
#     }

#     inline = [
#       "sudo wg-quick down wg0",
#       "sudo wg-quick up wg0"
#     ]
#   }

#   depends_on = [
#     module.wg
#   ]
# }
