data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_owner]
}

data "aws_subnet" "main" {
  cidr_block = var.subnet_cidr
  vpc_id     = var.vpc_id
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}

data "aws_kms_alias" "sqs" {
  name = "alias/aws/sqs"
}
