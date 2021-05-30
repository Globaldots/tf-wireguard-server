terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.70.0"
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
