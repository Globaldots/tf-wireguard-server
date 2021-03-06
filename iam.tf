#######################################
# IAM role & instance profile for EC2 #
#######################################
resource "aws_iam_role" "main" {
  name        = "wireguard-configuration-${data.aws_region.current.name}-${var.name_suffix}"
  description = "IAM role to pull Wireguard configuration from ${aws_s3_bucket.main.id} S3 bucket"
  path        = "/wireguard/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name = "AllowS3GetObject"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
            "s3:GetObject"
          ],
          "Resource" : [
            data.aws_kms_alias.s3.target_key_arn,
            "arn:aws:s3:::${aws_s3_bucket.main.id}/*"
          ]
        }
      ]
    })
  }

  inline_policy {
    name = "AllowASGCompleteLifecycleAction"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["autoscaling:CompleteLifecycleAction"],
          "Resource" : ["arn:aws:autoscaling:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/${local.asg_name_prefix}*"]
        }
      ]
    })
  }

  # FIXME:
  # This policy is needed as a workaround to allow instance updating certain Target Group values
  # through userdata script while Terraform doesn't support that action directly — 
  # https://github.com/hashicorp/terraform-provider-aws/issues/17227.
  inline_policy {
    name = "AllowUpdateLBTargetGroupAttrs"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["elasticloadbalancing:ModifyTargetGroupAttributes"],
          "Resource" : [aws_lb_target_group.main.arn]
        }
      ]
    })
  }

  tags = var.tags
}

################################################
# Attaches a Managed IAM Policy to an IAM role #
################################################
resource "aws_iam_role_policy_attachment" "main" {
  count      = length(local.ec2_iam_policy_names)
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/${local.ec2_iam_policy_names[count.index]}"
}

####################################
# Provides an IAM instance profile #
####################################
resource "aws_iam_instance_profile" "main" {
  name = "wireguard-configuration-${data.aws_region.current.name}-${var.name_suffix}"
  role = aws_iam_role.main.name
  tags = var.tags
}

#######################
# IAM role for Lambda #
#######################
resource "aws_iam_role" "main_lambda" {
  name               = "wireguard-restart-lambda-${data.aws_region.current.name}-${var.name_suffix}"
  description        = "IAM role for Lambda function which restarts Wireguard instances when configuration changes occur"
  path               = "/wireguard/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  inline_policy {
    name = "AllowGetSQSMessages"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
            "sqs:ChangeMessageVisibility",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:ReceiveMessage",
            "sns:Publish"
          ],
          "Resource" : [
            aws_kms_key.main.arn,
            aws_sqs_queue.main.arn,
            aws_sns_topic.main_lambda.arn
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeInstances",
            "ec2:DescribeTags",
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:SendCommand",
          ],
          "Resource" : [
            "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetCommandInvocation",
          ],
          "Resource" : [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:SendCommand",
          ],
          "Resource" : [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:document/${local.ssm_document_name}"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams",
            "logs:GetLogEvents",
            "logs:PutRetentionPolicy",
          ],
          "Resource" : [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*",
          ]
        },
      ]
    })
  }
}
