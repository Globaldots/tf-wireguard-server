/*
* # tf-wireguard-server
* WireGuard® is an extremely simple yet fast and modern VPN that utilizes state-of-the-art cryptography. It aims to be faster, simpler, leaner, and more useful than IPsec, while avoiding the massive headache. It intends to be considerably more performant than OpenVPN.
* 
* This repository contains Terraform code to provision Wireguard server in a highly-available, scalable and secure manner, utilizing benefits of AWS infrastructure. The solution is built on top of such services as EC2, NLB, S3, SQS, Lambda, SSM, CloudWatch, SNS and more.
* 
* ## Design
* ![Wireguard Multi AZ design](./docs/aws-wireguard-multi-az-no-app.svg)
* 
* Above diagram demonstrates highly-available Wireguard setup in a single AWS region. Reference code is located under `examples/multi-az` folder.
* 
* ### Clients connections
* Multiple EC2 instances are spread across several availability zones within a region. Clients connections get distributed to the instances through highly-available Network Load Balancer with Route53 DNS record attached (optional).
* 
* ### Configuration changes
* Wireguard configuration file is being generated by Terraform and stored in S3 bucket with enabled versioning and access logs. Every S3 bucket content change triggers Lambda function through SQS queue. Lambda function executes predefined SSM document on all Wireguard EC2 instances. SSM document is configured to upload the latest configuration file to the instances and reload Wireguard interface.
* Also, Wireguard instances have PreUp hook enabled which additionally ensures that they use the latest configuration file available in S3.
* 
* ## Prerequisites
* * Terraform 0.15+
* * Terragrunt 0.28.7+ (optional but recommended)
* * Configured CLI access to target AWS account
* 
* ## Quick start
* There are multiple examples under `examples` folder. Please, choose the one that fits your needs best. Every example comes with its own `README.md` file.
* Example code snippets for simplicity reasons don't define all variables which module exposes. So if you want to get a better understanding of all available options, please review the table below.
*/

###################
# Launch template #
###################
resource "aws_launch_template" "main" {
  name                    = local.wg_server_name
  image_id                = data.aws_ami.ami.id
  instance_type           = var.ec2_instance_type
  key_name                = var.ssh_keypair_name
  user_data               = local.ec2_user_data
  disable_api_termination = var.enable_termination_protection ? false : true
  vpc_security_group_ids  = [aws_security_group.instance.id]
  ebs_optimized           = true

  block_device_mappings {
    device_name = data.aws_ami.ami.root_device_name
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_type           = "gp2"
      volume_size           = 25
      kms_key_id            = data.aws_kms_alias.ebs.id
    }
  }

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
