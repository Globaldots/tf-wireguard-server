#############################
# CPU metric for Cloudwatch #
#############################
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count                     = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name                = "wireguard-${var.name_suffix}-high-cpu-utilization"
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
  alarm_actions             = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

####################
# EC2 status check #
####################
resource "aws_cloudwatch_metric_alarm" "status_checks" {
  count                     = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name                = "wireguard-${var.name_suffix}-status-checks-failed"
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
  alarm_actions             = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_used" {
  count               = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name          = "wireguard-${var.name_suffix}-high-memory-usage"
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
  alarm_actions             = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags
}

resource "aws_cloudwatch_metric_alarm" "disk_used" {
  count               = var.enable_cloudwatch_monitoring ? 1 : 0
  alarm_name          = "wireguard-${var.name_suffix}-high-disk-usage"
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
  alarm_actions             = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions                = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  insufficient_data_actions = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                      = var.tags
}

