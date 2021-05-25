#############################
# CPU metric for Cloudwatch #
#############################
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "wireguard-${var.name_suffix}-high-cpu-utilization"
  alarm_description   = "Alarm gets triggered by high CPU utilization of wireguard-${var.name_suffix} EC2 instances"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  actions_enabled     = true
  alarm_actions       = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions          = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                = var.tags

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

####################
# EC2 status check #
####################
resource "aws_cloudwatch_metric_alarm" "status_checks" {
  alarm_name          = "wireguard-${var.name_suffix}-status-checks-failed"
  alarm_description   = "Alarm gets triggered by failed EC2 status checks of wireguard-${var.name_suffix} instances"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  evaluation_periods  = "5"
  datapoints_to_alarm = "3"
  statistic           = "Average"
  threshold           = "0"
  treat_missing_data  = "breaching"
  actions_enabled     = true
  alarm_actions       = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  ok_actions          = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? [aws_sns_topic.main[0].arn] : []
  tags                = var.tags

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}
