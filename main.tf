/*
 * ## tf-wireguard-server
 * This is the main code to deploy Wireguard VPN Server on top of AWS Amazon EC2, which includes
 * (ASG, ENI, EIP, launch template, and many more).
 *
 * Please check folder example/ to see how this module can be provisioned
 *
 * Please, find deployment instruction in README.md file of repository root.
*/

#######################
# ENI                 #
#######################
resource "aws_network_interface" "main" {
  subnet_id         = data.aws_subnet.main.id
  security_groups   = var.security_group_ids
  source_dest_check = false
  tags              = var.tags
}

#######################
# Elastic IP          #
#######################
resource "aws_eip" "main" {
  vpc               = true
  network_interface = aws_network_interface.main.id
  tags              = var.tags
}

#######################
# Launch template     #
#######################
resource "aws_launch_template" "main" {
  name          = local.wg_server_name
  image_id      = data.aws_ami.ami.id
  instance_type = var.ec2_instance_type
  key_name      = var.ssh_keypair_name
  user_data     = local.user_data

  iam_instance_profile {
    arn = aws_iam_instance_profile.main.arn
  }

  dynamic "credit_specification" {
    for_each = length(regexall("^t", var.ec2_instance_type)) == 0 ? tomap({}) : tomap({ "cpu_credits" = "standard" })
    content {
      cpu_credits = credit_specification.value
    }
  }

  network_interfaces {
    delete_on_termination = false
    network_interface_id  = aws_network_interface.main.id
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = local.wg_server_name
      },
      var.tags
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

######################
# Autoscaling group  #
######################
resource "aws_autoscaling_group" "main" {
  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }

  availability_zones = [data.aws_subnet.main.availability_zone]

  dynamic "tag" {
    for_each = merge(var.tags, { "wireguard-server-name" : local.wg_server_name })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true

    }
  }

  depends_on = [aws_s3_bucket_object.main]
}
