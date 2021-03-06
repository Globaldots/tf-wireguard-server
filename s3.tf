#########################################
# S3 bucket for Wireguard configuration #
#########################################
resource "aws_s3_bucket" "main" {
  bucket        = "${var.s3_bucket_name_prefix}-wireguard-configuration-${var.name_suffix}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.main_logs.id
  }

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name_prefix}-wireguard-configuration-${var.name_suffix}",
                "arn:aws:s3:::${var.s3_bucket_name_prefix}-wireguard-configuration-${var.name_suffix}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF

  tags = merge(var.tags, { "${local.wg_identification_tag_name}" : local.wg_server_name })
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#################################################
# Wireguard configuration S3 bucket access logs #
#################################################
resource "aws_s3_bucket" "main_logs" {
  # tfsec:ignore:AWS005
  # tfsec:ignore:AWS077
  bucket        = "${var.s3_bucket_name_prefix}-wireguard-configuration-${var.name_suffix}-logs"
  acl           = "log-delivery-write"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        // https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html
        // KMS isn't supported for log aggregation buckets
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(var.tags, { "${local.wg_identification_tag_name}" : local.wg_server_name })
}

resource "aws_s3_bucket_public_access_block" "main_logs" {
  bucket = aws_s3_bucket.main_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################
# S3 bucket for LB access logs #
################################
resource "aws_s3_bucket" "access_logs" {
  # tfsec:ignore:AWS077
  # tfsec:ignore:AWS002
  bucket        = "${var.s3_bucket_name_prefix}-wireguard-access-logs-${var.name_suffix}"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        // https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html
        // KMS isn't supported for log aggregation buckets
        sse_algorithm = "AES256"
      }
    }
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.s3_bucket_name_prefix}-wireguard-access-logs-${var.name_suffix}/lb-main/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.s3_bucket_name_prefix}-wireguard-access-logs-${var.name_suffix}/lb-main/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.s3_bucket_name_prefix}-wireguard-access-logs-${var.name_suffix}"
    }
  ]
}
EOF

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 120
    }
  }

  tags = merge(var.tags, { "${local.wg_identification_tag_name}" : local.wg_server_name })
}

#############################################################
# Manages S3 bucket-level Public Access Block configuration #
#############################################################
resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################################
# Push message to SQS when Wireguard configuration changed #
############################################################
resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  queue {
    queue_arn     = aws_sqs_queue.main.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".conf"
  }

  depends_on = [aws_sqs_queue_policy.main]
}

################################################
# Upload Wireguard configuration from template #
################################################
resource "aws_s3_bucket_object" "main" {
  bucket  = aws_s3_bucket.main.id
  key     = "${local.wg_interface_name}.conf"
  content = local.wg_server_config
  tags    = var.tags
}
