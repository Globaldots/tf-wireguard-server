locals {
  name = format("%s-%s", var.name_prefix, random_pet.this.id)
  user_data = base64encode(
    templatefile(
      "${path.module}/templates/userdata.sh.tpl",
      {
        region        = var.aws_region
        ssm_parameter = aws_ssm_parameter.this.name
      }
    )
  )
}
