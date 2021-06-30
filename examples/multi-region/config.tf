terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.44.0"
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
  alias = "region_a"
  # region is being defined by AWS_REGION environmental variable
}

provider "aws" {
  alias  = "region_b"
  region = var.region_b
}

provider "wireguard" {}
