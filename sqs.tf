###################################
# SQS queues for S3 notifications #
###################################
resource "aws_sqs_queue" "main_dead_letter" {
  name              = "wireguard-configuration-dead-letter-${var.name_suffix}"
  kms_master_key_id = "alias/aws/sqs"

  tags = var.tags
}

# Use KMS CMK here, since we need to attach a specific policy to the key.
# Terraform can't modify policies of AWS-managed keys.
resource "aws_kms_key" "main" {
  description         = "sqs-wireguard-${var.name_suffix}-main"
  enable_key_rotation = true

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "KMSWireguardPolicy",
    "Statement": [
        {
          "Sid": "AllowFullAccessByRoot",
          "Effect": "Allow",
          "Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"},
          "Action": "kms:*",
          "Resource": "*"
        },
        {
            "Sid": "AllowAccessFromS3",
            "Effect": "Allow",
            "Principal": {
                "Service": "s3.amazonaws.com"
            },
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": "*"
        }
    ]
}
EOF

  tags = var.tags
}

resource "aws_kms_alias" "main" {
  name          = "alias/sqs"
  target_key_id = aws_kms_key.main.key_id
}

resource "aws_sqs_queue" "main" {
  name                       = "wireguard-configuration-${var.name_suffix}"
  visibility_timeout_seconds = 3600
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.main_dead_letter.arn}\",\"maxReceiveCount\":3}"
  kms_master_key_id          = aws_kms_key.main.id

  tags = var.tags
}
###################################################################################################
# Allows you to set a policy of an SQS Queue while referencing ARN of the queue within the policy #
###################################################################################################
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id
  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Id": "SQSAccessPolicy",
  "Statement": [
    {
      "Sid": "AllowAccessFromS3",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.main.arn}",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:*:*:${aws_s3_bucket.main.id}"
        }
      }
    }
  ]
}
EOF
}
