###################################
# SQS queues for S3 notifications #
###################################
resource "aws_sqs_queue" "main_dead_letter" {
  name              = "wireguard-configuration-dead-letter-${var.name_suffix}"
  kms_master_key_id = "alias/aws/sqs"

  tags = var.tags
}

resource "aws_sqs_queue" "main" {
  name                       = "wireguard-configuration-${var.name_suffix}"
  visibility_timeout_seconds = 3600
  redrive_policy             = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.main_dead_letter.arn}\",\"maxReceiveCount\":3}"
  # TODO: need to enable encryption here but currently that breaks S3 notifications
  # kms_master_key_id          = "alias/aws/sqs"

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
      "Action": "SQS:SendMessage",
      "Resource": "${aws_sqs_queue.main.arn}",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        },
        "ArnLike": {
          "aws:SourceArn": "arn:aws:s3:::${aws_s3_bucket.main.id}"
        }
      }
    }
  ]
}
EOF

  # TODO: add this policy as soon as KMS encrpytion is enabled for SQS queue
  # {   "Sid": "AllowS3KMSDecrypt",
  #     "Effect": "Allow",
  #     "Principal": {
  #         "Service": "s3.amazonaws.com"
  #     },
  #     "Action": [
  #         "kms:GenerateDataKey",
  #         "kms:Decrypt"
  #     ],
  #     "Resource": [
  #       "${data.aws_kms_alias.sqs.target_key_arn}"
  #     ]
  # }

}
