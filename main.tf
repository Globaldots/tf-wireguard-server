/*
 * ## tf-wireguard-server
 * This is the main code to deploy Wireguard VPN Server on top of AWS Amazon EC2, which includes
 * (ASG, ENI, EIP, launch template, and many more).
 *
 * Please check folder example/ to see how this module can be provisioned
 *
 * Please, find deployment instruction in README.md file of repository root.
*/

###################
# Launch template #
###################
resource "aws_launch_template" "main" {
  name                    = local.wg_server_name
  image_id                = data.aws_ami.ami.id
  instance_type           = var.ec2_instance_type
  key_name                = var.ssh_keypair_name
  user_data               = local.user_data
  disable_api_termination = var.enable_termination_protection ? false : true
  vpc_security_group_ids  = [aws_security_group.instance.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.main.arn
  }

  dynamic "credit_specification" {
    for_each = length(regexall("^t", var.ec2_instance_type)) == 0 ? tomap({}) : tomap({ "cpu_credits" = "standard" })
    content {
      cpu_credits = credit_specification.value
    }
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
    ignore_changes        = [image_id]
  }
}

#####################
# Autoscaling group #
#####################
resource "aws_autoscaling_group" "main" {
  min_size         = var.wg_ha_instance_min_count
  max_size         = var.wg_ha_instance_max_count
  desired_capacity = var.wg_ha_instance_desired_count

  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]
  }

  vpc_zone_identifier = [for item in data.aws_subnet.main_private : item.id]

  dynamic "tag" {
    for_each = merge(var.tags, { "${local.wg_identification_tag_name}" : local.wg_server_name })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true

    }
  }

  depends_on = [aws_s3_bucket_object.main]
}

####################################
# Auto Scaling Attachment resource #
####################################
resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.id
  alb_target_group_arn   = aws_lb_target_group.main.arn
}
