data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

# Use this data source to get the ID of a registered AMI
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Provides details about a specific VPC subnet
data "aws_subnet" "main_private" {
  count      = length(var.private_subnet_cidrs)
  cidr_block = var.private_subnet_cidrs[count.index]
  vpc_id     = var.vpc_id
}

# Provides details about a specific VPC subnet
data "aws_subnet" "main_public" {
  count      = length(var.public_subnet_cidrs)
  cidr_block = var.public_subnet_cidrs[count.index]
  vpc_id     = var.vpc_id
}

# Use this data source to get the ARN of a KMS key alias
data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

# Use this data source to get the ARN of a KMS key alias
data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}

# Provides details about a specific VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Provides details about a specific Route 53 Hosted Zone
data "aws_route53_zone" "main" {
  count = var.dns_zone_name == "" ? 0 : 1
  name  = "${replace(var.dns_zone_name, "/\\.$/", "")}."
}
