locals {
  wg_server_name = "wireguard-${var.name_suffix}"
  user_data = base64encode(
    templatefile(
      "${path.module}/templates/userdata.sh.tpl",
      {
        region         = data.aws_region.current.name
        s3_bucket_name = aws_s3_bucket.main.id
      }
    )
  )
}
