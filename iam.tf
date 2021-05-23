######################################################
# IAM role & instance profile for S3 access from EC2 #
######################################################
resource "aws_iam_role" "main" {
  name        = "wireguard-configuration-${var.name_suffix}"
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

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "main" {
  count      = length(local.ec2_iam_policy_names)
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/${local.ec2_iam_policy_names[count.index]}"
}

resource "aws_iam_instance_profile" "main" {
  name = "wireguard-configuration-${var.name_suffix}"
  role = aws_iam_role.main.name
  tags = var.tags
}

#######################
# IAM role for Lambda #
#######################
resource "aws_iam_role" "main_lambda" {
  name               = "wireguard-${var.name_suffix}-restart-lambda"
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
            data.aws_kms_alias.sqs.target_key_arn,
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
            "logs:CreateLogGroup",
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
