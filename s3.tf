##############################################
# S3 bucket to store Wireguard configuration #
##############################################
resource "aws_s3_bucket" "main" {
  bucket = "${var.s3_bucket_name_prefix}-wireguard-configuration-${var.name_suffix}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
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

  versioning {
    enabled = true
  }

  tags = merge(var.tags, { "wireguard-server-name" : "${local.wg_server_name}" })
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

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

############################################################
# Upload Wireguard configuration from template #
############################################################
resource "aws_s3_bucket_object" "main" {
  bucket = aws_s3_bucket.main.id
  key    = "wg0.conf"
  content = templatefile("${path.module}/templates/wg0.conf.tmpl", {
    name           = "${local.wg_server_name}"
    address        = "${cidrhost("${var.wg_cidr}", 1)}/${replace(var.wg_cidr, "/.*\\//", "")}"
    listen_port    = "${var.wg_listen_port}"
    s3_bucket_name = "${aws_s3_bucket.main.id}"
    region         = "${aws_s3_bucket.main.region}"
    cidr           = "${var.wg_cidr}"
    private_key    = "${var.wg_private_key}"
    dns_server     = "${var.wg_dns_server}"
    peers          = "${var.wg_peers}"
  })
  tags = var.tags
}
