###############################
# EC2 instance security group #
###############################
resource "aws_security_group" "instance" {
  name        = "wireguard-instance-${var.name_suffix}"
  description = "Group for Wireguard EC2 instances (${var.name_suffix})"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = "wireguard-instance-${var.name_suffix}"
  })
}

###########################################
# Provides a security group rule resource #
###########################################
resource "aws_security_group_rule" "instance-ingress-1" {
  count             = length(var.wg_listen_ports)
  type              = "ingress"
  from_port         = var.wg_listen_ports[count.index]
  to_port           = var.wg_listen_ports[count.index]
  cidr_blocks       = var.wg_allow_connections_from_subnets
  protocol          = "udp"
  security_group_id = aws_security_group.instance.id
  description       = "Allow UDP inbound to Wireguard ports"
}

###########################################
# Provides a security group rule resource #
###########################################
resource "aws_security_group_rule" "instance-ingress-2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = [data.aws_vpc.main.cidr_block]
  protocol          = "tcp"
  security_group_id = aws_security_group.instance.id
  description       = "Allow TCP inbound for SSH & NLB healthcheck from VPC CIDR"
}

###########################################
# Provides a security group rule resource #
###########################################
resource "aws_security_group_rule" "instance-ingress-3" {
  count             = length(local.prometheus_exporters_ports) * (var.prometheus_exporters_enable ? 1 : 0)
  type              = "ingress"
  from_port         = local.prometheus_exporters_ports[count.index]
  to_port           = local.prometheus_exporters_ports[count.index]
  cidr_blocks       = [data.aws_vpc.main.cidr_block]
  protocol          = "tcp"
  security_group_id = aws_security_group.instance.id
  description       = "Allow TCP inbound for Prometheus Exporters from VPC CIDR"
}

###########################################
# Provides a security group rule resource #
###########################################
resource "aws_security_group_rule" "instance-egress-1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"] # tfsec:ignore:AWS007
  protocol          = "-1"
  security_group_id = aws_security_group.instance.id
  description       = "Allow outbound to anywhere"
}
