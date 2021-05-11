resource "aws_sns_topic" "main" {
  count             = length(var.cloudwatch_alerts_phone_numbers) + length(var.cloudwatch_alerts_emails) > 0 ? 1 : 0
  name              = "wireguard-${var.name_suffix}-cloudwatch-alarms"
  kms_master_key_id = "alias/aws/sns"
  policy            = <<EOF
{
   "Version":"2008-10-17",
   "Id":"AllowPushFromCloudWatch",
   "Statement":[
      {
         "Sid":"AllowPublishEvents",
         "Effect":"Allow",
         "Principal":{
            "Service": ["events.amazonaws.com", "cloudwatch.amazonaws.com"]
         },
         "Action":[
            "SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish",
            "SNS:Receive"
         ],
         "Resource":"arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:wireguard-${var.name_suffix}-cloudwatch-alarms"
      }
   ]
}
EOF
}

resource "aws_sns_topic_subscription" "text" {
  count     = length(var.cloudwatch_alerts_phone_numbers)
  topic_arn = aws_sns_topic.main[0].arn
  protocol  = "sms"
  endpoint  = var.cloudwatch_alerts_phone_numbers[count.index]
}

# Email subscriptions must be confirmed by clicking on the URL in confirmation email.
resource "aws_sns_topic_subscription" "email" {
  count     = length(var.cloudwatch_alerts_emails)
  topic_arn = aws_sns_topic.main[0].arn
  protocol  = "email"
  endpoint  = var.cloudwatch_alerts_emails[count.index]
}
