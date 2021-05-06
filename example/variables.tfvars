vpc_cidr = "10.0.0.0/16"
vpc_availability_zones = [
    "eu-central-1a",
    "eu-central-1b",
  ]
vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
ec2_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDyQd3GtSqa9baNUZyrTN8pWBxV5wHEUoHxeE1z5Yi66szMbT1tRjt/vOMLpHFzyb3Zbn0mdDGvcyrJocS0lP00ZQKTJi5e5WnVPaeGKU9nAy09aV33NsmuIi3y4jNExft4KXBUM6dfMWVu4oBWPL4kCuHqtupzYmlnoGHheq2xbaoqAVQAEJs3ulmKbXxoqzIua5J0A1qo60UYQrLqjlVOV1qLXMcpJtshcGeDb9myZAttamNmFM5AMLZProMY8A3yO/V3aQtCoBzl4xdtlCEQpzlBJOr85lbGTyEh63NqEyW980D65AJHXuwrjJq9UJ8jNcX8VIyC9U6kiQsVwZAZFr9Q6h0E5z/l283yk3vdNTOJu6WR3Hsu7YCKU2+T7QcP31Qdc8bCwbOOF5UqCDcvDn1P+ip5o9j+sGv/u3k6bzIQWo8QKJOaoBiTKzhnSUfJhLuPWPNFylx69TgDaCd20ejwm4DSre+WSitPhS86tdCN2zo/6YupDArvzvwC4Ll9PeVNz9a8wE2kTOfcPd8pkb8rNRSiDyPTYnZ/iYlQre4z/w+NNH7ZVaVzCytsinWQer0jnSV1ogxm8ZTWnkLckt/demAOUzT/y6dhjrjcaxhcpm84WohCHxcMWudSDzsuS/qDxXevjLKp2YP/QzmW8quGu75iHYkq1pgkYRyJ4Q== demo@key"
s3_bucket_name_prefix = "gd"
tags = {
  Managed-by = "Terraform"
}
enable_termination_protection = false
wg_allow_connections_from_subnets = ["0.0.0.0/0"]
dns_zone_name = "egorzp.info"
