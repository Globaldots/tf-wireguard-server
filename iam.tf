######################################################
# IAM role & instance profile for S3 access from EC2 #
######################################################
resource "aws_iam_role" "main" {
  name        = "wireguard-configuration--${var.name_suffix}"
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
    name = "my_inline_policy"

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
            "${data.aws_kms_alias.s3.target_key_arn}",
            "arn:aws:s3:::${aws_s3_bucket.main.id}/*"
          ]
        }
      ]
    })
  }

  tags = var.tags
}

resource "aws_iam_instance_profile" "main" {
  name = "wireguard-configuration-${var.name_suffix}"
  role = aws_iam_role.main.name
  tags = var.tags
}
