################################
# EC2 instance security group  #
################################
resource "aws_security_group" "instance" {
  name        = "wireguard-instance-${var.name_suffix}"
  description = "Group for Wireguard EC2 instances (${var.name_suffix})"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = "wireguard-instance-${var.name_suffix}"
  })
}

resource "aws_security_group_rule" "instance-ingress-1" {
  count             = length(var.wg_listen_ports)
  type              = "ingress"
  from_port         = var.wg_listen_ports[count.index]
  to_port           = var.wg_listen_ports[count.index]
  cidr_blocks       = var.wg_allow_connections_from_subnets
  protocol          = "udp"
  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "instance-ingress-2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = [data.aws_vpc.main.cidr_block]
  protocol          = "tcp"
  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "instance-egress-1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "all"
  security_group_id = aws_security_group.instance.id
}
