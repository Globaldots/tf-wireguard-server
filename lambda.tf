####################################################################
# Generates an archive from content, a file, or directory of files #
####################################################################
data "archive_file" "main" {
  type        = "zip"
  source_file = "${path.module}/lambda/main.py"
  output_path = "${path.module}/lambda/restart-wireguard.zip"
}

#######################################
# Provides a Lambda Function resource #
#######################################
resource "aws_lambda_function" "main" {
  function_name = "wireguard-${var.name_suffix}-restart-instances"
  description   = "Function to restart Wireguard (${var.name_suffix}) when configuration file was changed"
  filename      = "${path.module}/lambda/restart-wireguard.zip"
  role          = aws_iam_role.main_lambda.arn
  handler       = "main.lambda_handler"

  dead_letter_config {
    target_arn = aws_sns_topic.main_lambda.arn
  }

  source_code_hash = data.archive_file.main.output_base64sha256

  runtime = "python3.8"
  timeout = 900

  environment {
    variables = {
      SSM_DOCUMENT_NAME = local.ssm_document_name
      EC2_TARGET_TAGS   = format("{\"%s\":\"%s\"}", local.wg_identification_tag_name, local.wg_server_name)
      TIMEOUT_SEC       = var.wg_restart_lambda_timeout_sec
      MAX_ERRORS        = var.wg_restart_lambda_max_errors_count
    }
  }

  tags = var.tags
}

##########################################
# Provides a Lambda event source mapping #
##########################################
resource "aws_lambda_event_source_mapping" "main" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.main.arn
  enabled          = true
  function_name    = aws_lambda_function.main.arn
}
