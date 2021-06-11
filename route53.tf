################################
# DNS record for load balancer #
################################
resource "aws_route53_record" "main" {
  count   = var.dns_zone_name == "" ? 0 : 1
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = "wireguard-${var.name_suffix}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
