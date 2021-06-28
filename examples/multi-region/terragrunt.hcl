remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "wireguard-demo-setup-tf-state-${get_aws_account_id()}"

    key            = "${basename(get_terragrunt_dir())}/terraform.tfstate"
    region         = "${get_env("AWS_REGION", "eu-central-1")}"
    encrypt        = true
    dynamodb_table = "wireguard-demo-setup-tf-state"
  }
}
