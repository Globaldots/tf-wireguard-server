/*
 * This is the main code to deploy Wireguard VPN Server on top of AWS Amazon EC2, which includes
 * (subnets, ASG, ENI, EIP, launch template, and many more).
 *
 * Please check folder example/ to see how this module can be provisioned
 *
 * Please, find deployment instruction in README.md file of repository root.
*/

#############################
# Random pet name generator #
#############################
resource "random_pet" "this" {
  keepers = {
    wg_private_key = var.wg_private_key
  }
}

#######################
# ENI                 #
#######################
resource "aws_network_interface" "this" {
  subnet_id         = var.subnet_id
  security_groups   = var.vpc_security_group_ids
  source_dest_check = false
}

#######################
# Elastic IP          #
#######################
resource "aws_eip" "this" {
  vpc               = true
  network_interface = aws_network_interface.this.id
}

#######################
# Launch template     #
#######################
resource "aws_launch_template" "launch_template" {
  name_prefix = local.name

  image_id      = data.aws_ami.ami.id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = module.iam_assumable_role.this_iam_instance_profile_arn
  }

  user_data = local.user_data

  key_name = var.key_name

  credit_specification {
    cpu_credits = "standard" # for T2/T3 instances to avoid extra costs
  }

  network_interfaces {
    delete_on_termination = false
    network_interface_id  = aws_network_interface.this.id
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = local.name
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
resource "aws_autoscaling_group" "this" {
  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }

  availability_zones = [data.aws_subnet.this.availability_zone]
}
