resource "random_pet" "this" {
  keepers = {
    wg_private_key = var.wg_private_key
  }
}

resource "aws_network_interface" "this" {
  subnet_id         = var.subnet_id
  security_groups   = var.vpc_security_group_ids
  source_dest_check = false
}

resource "aws_eip" "this" {
  vpc               = true
  network_interface = aws_network_interface.this.id
}

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

  # https://github.com/hashicorp/terraform-provider-aws/pull/7615
  availability_zones = [data.aws_subnet.this.availability_zone]
}

data "aws_subnet" "this" {
  id = var.subnet_id
}
