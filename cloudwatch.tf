##############
# Log groups #
##############
resource "aws_kms_key" "cloudwatch_logs" {
  description         = "KMS key for CloudWatch Logs"
  enable_key_rotation = true
  policy              = <<EOF
{
 "Version": "2012-10-17",
    "Id": "KMSCloudWatchLogs",
    "Statement": [
        {
            "Sid": "AllowFullAccessByRoot",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.${data.aws_region.current.name}.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
                }
            }
        }    
    ]
}
EOF
  tags                = var.tags
}

resource "aws_kms_alias" "cloudwatch_logs" {
  name          = "alias/cloudwatch-${var.name_suffix}"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}

resource "aws_cloudwatch_log_group" "main" {
  for_each          = local.cloudwatch_log_groups
  name              = each.value
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn
  tags              = var.tags
}

###################################
# High CPU usage CloudWatch alert #
###################################
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count                     = var.cloudwatch_monitoring_enable ? 1 : 0
  alarm_name                = "ec2-high-cpu-utilization-wireguard-${var.name_suffix}"
  alarm_description         = "Alarm gets triggered by high CPU utilization of wireguard-${var.name_suffix} EC2 instances"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  treat_missing_data        = "breaching"
  actions_enabled           = true
  alarm_actions             = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

#############################################
# EC2 status checks failed CloudWatch alert #
#############################################
resource "aws_cloudwatch_metric_alarm" "status_checks" {
  count                     = var.cloudwatch_monitoring_enable ? 1 : 0
  alarm_name                = "ec2-status-checks-failed-wireguard-${var.name_suffix}"
  alarm_description         = "Alarm gets triggered by failed EC2 status checks of wireguard-${var.name_suffix} instances"
  comparison_operator       = "GreaterThanThreshold"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  evaluation_periods        = "5"
  datapoints_to_alarm       = "3"
  statistic                 = "Average"
  threshold                 = "0"
  treat_missing_data        = "breaching"
  actions_enabled           = true
  alarm_actions             = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

############################################
# High memory (RAM) usage CloudWatch alert #
############################################
resource "aws_cloudwatch_metric_alarm" "memory_used" {
  count               = var.cloudwatch_monitoring_enable ? 1 : 0
  alarm_name          = "ec2-high-memory-usage-wireguard-${var.name_suffix}"
  alarm_description   = "Alarm gets triggered when memory (RAM) usage of wireguard-${var.name_suffix} EC2 instances hits 80%"
  comparison_operator = "GreaterThanThreshold"

  metric_query {
    id          = "mem_used_percent"
    expression  = "CEIL(100*(mem_used/mem_total))"
    label       = "mem_used_percent"
    return_data = "true"
  }

  metric_query {
    id = "mem_total"

    metric {
      metric_name = "mem_total"
      namespace   = local.cloudwatch_agent_metrics_namespace
      period      = "60"
      stat        = "Average"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.main.name
      }
    }
  }

  metric_query {
    id = "mem_used"

    metric {
      metric_name = "mem_used"
      namespace   = local.cloudwatch_agent_metrics_namespace
      period      = "60"
      stat        = "Average"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.main.name
      }
    }
  }

  evaluation_periods        = "5"
  datapoints_to_alarm       = "3"
  threshold                 = "80"
  treat_missing_data        = "breaching"
  actions_enabled           = true
  alarm_actions             = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags
}

##############################################
# High disk (storage) usage CloudWatch alert #
##############################################
resource "aws_cloudwatch_metric_alarm" "disk_used" {
  count               = var.cloudwatch_monitoring_enable ? 1 : 0
  alarm_name          = "ec2-high-disk-usage-wireguard-${var.name_suffix}"
  alarm_description   = "Alarm gets triggered when disk storage usage of wireguard-${var.name_suffix} EC2 instances hits 80%"
  comparison_operator = "GreaterThanThreshold"

  metric_query {
    id          = "disk_used_percent"
    expression  = "CEIL(100*(disk_used/disk_total))"
    label       = "disk_used_percent"
    return_data = "true"
  }

  metric_query {
    id = "disk_total"

    metric {
      metric_name = "disk_total"
      namespace   = local.cloudwatch_agent_metrics_namespace
      period      = "60"
      stat        = "Average"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.main.name
      }
    }
  }

  metric_query {
    id = "disk_used"

    metric {
      metric_name = "disk_used"
      namespace   = local.cloudwatch_agent_metrics_namespace
      period      = "60"
      stat        = "Average"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.main.name
      }
    }
  }

  evaluation_periods        = "5"
  datapoints_to_alarm       = "3"
  threshold                 = "80"
  treat_missing_data        = "breaching"
  actions_enabled           = true
  alarm_actions             = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags
}

############################################
# Lambda function failure CloudWatch alert #
############################################
resource "aws_cloudwatch_log_metric_filter" "main" {
  count          = var.cloudwatch_monitoring_enable ? 1 : 0
  name           = "wireguard-${var.name_suffix}-lambda-reload-config-failure"
  pattern        = "\"INFO | All Wireguard instances have been reloaded with no issues\""
  log_group_name = local.cloudwatch_log_groups["lambda"]

  metric_transformation {
    name          = local.cloudwatch_lambda_status_metric_name
    namespace     = "lambda"
    value         = "1"
    default_value = "0"
  }

  depends_on = [aws_cloudwatch_log_group.main]
}

resource "aws_cloudwatch_metric_alarm" "lambda_failure" {
  count                     = var.cloudwatch_monitoring_enable ? 1 : 0
  alarm_name                = "wireguard-${var.name_suffix}-lambda-reload-config-failure"
  alarm_description         = "Alarm gets triggered when Lambda function which reloads wireguard-${var.name_suffix} instances fails"
  comparison_operator       = "LessThanThreshold"
  metric_name               = local.cloudwatch_lambda_status_metric_name
  namespace                 = "lambda"
  period                    = "60"
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  statistic                 = "Maximum"
  threshold                 = "1"
  treat_missing_data        = "ignore"
  actions_enabled           = true
  alarm_actions             = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(concat(var.cloudwatch_alerts_phone_numbers, var.cloudwatch_alerts_emails)) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags

  depends_on = [
    aws_cloudwatch_log_metric_filter.main
  ]
}
