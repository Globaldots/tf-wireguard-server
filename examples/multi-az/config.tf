terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.46.0"
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

provider "aws" {}
provider "wireguard" {}
