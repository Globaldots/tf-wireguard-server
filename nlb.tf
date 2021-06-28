###################################
# Load balancer for EC2 instances #
###################################
resource "aws_lb" "main" {
  name                             = "wireguard-${var.name_suffix}"
  internal                         = false # tfsec:ignore:AWS005
  load_balancer_type               = "network"
  subnets                          = [for item in data.aws_subnet.main_public : item.id]
  enable_cross_zone_load_balancing = true

  access_logs {
    bucket  = aws_s3_bucket.access_logs.id
    prefix  = "lb-main"
    enabled = true
  }

  enable_deletion_protection = var.enable_termination_protection ? false : true

  tags = var.tags
}

########################
# Target group for NLB #
########################
resource "aws_lb_target_group" "main" {
  name     = "wireguard-${var.name_suffix}"
  port     = 51820
  protocol = "UDP"
  vpc_id   = var.vpc_id
  tags     = var.tags

  deregistration_delay = 0

  # FIXME:
  # Option `deregistration_delay.connection_termination.enabled` needs to be set to `true`
  # but Terraform currently doesn't support it — https://github.com/hashicorp/terraform-provider-aws/issues/17227
  # For now that option is being set using `awscli` in EC2 userdata script.

  health_check {
    protocol            = "TCP"
    port                = 22
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  stickiness {
    enabled = true
    type    = "source_ip"
  }
}

#################
# NLB Listeners #
#################
resource "aws_lb_listener" "main" {
  count             = length(var.wg_listen_ports)
  load_balancer_arn = aws_lb.main.arn
  port              = var.wg_listen_ports[count.index]
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
