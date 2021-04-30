module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "3.15.0"

  role_name = local.name

  create_role             = true
  create_instance_profile = true

  role_requires_mfa = false

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.iam_policy.arn,
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]

  number_of_custom_role_policy_arns = 2

  tags = var.tags
}

module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "3.15.0"

  name        = local.name
  description = "IAM policy for wireguard server - ${var.name_prefix}"

  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [aws_ssm_parameter.this.arn]
  }
}
