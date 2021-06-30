data "aws_region" "current-a" {
  provider = aws.region_a
}

data "aws_region" "current-b" {
  provider = aws.region_b
}

data "aws_route53_zone" "main" {
  name = "${replace(var.dns_zone_name, "/\\.$/", "")}."
}
