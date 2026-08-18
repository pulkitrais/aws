resource "aws_sns_topic" "security_alerts" {
  name = "security-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "root_console_logins" {
  name        = "root-console-logins"
  description = "Detect root account console logins"

  event_pattern = jsonencode({
    source = ["signin.amazonaws.com"]
    detail-type = ["AWS Console Sign In via CloudTrail"]
    detail = {
      eventName = ["ConsoleLogin"]
      userIdentity = {
        type = ["Root"]
      }
      responseElements = {
        ConsoleLogin = ["Success"]
      }
    }
  })
}

resource "aws_cloudwatch_event_rule" "critical_api_events" {
  name        = "critical-cloudtrail-api-events"
  description = "Detect IAM policy attachment, SG rule changes and StopLogging"

  event_pattern = jsonencode({
    source = ["aws.iam", "aws.ec2", "aws.cloudtrail"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventName = [
        "AttachUserPolicy",
        "AttachRolePolicy",
        "AttachGroupPolicy",
        "PutUserPolicy",
        "PutRolePolicy",
        "PutGroupPolicy",
        "AuthorizeSecurityGroupIngress",
        "AuthorizeSecurityGroupEgress",
        "RevokeSecurityGroupIngress",
        "RevokeSecurityGroupEgress",
        "ModifySecurityGroupRules",
        "StopLogging"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "root_to_sns" {
  rule      = aws_cloudwatch_event_rule.root_console_logins.name
  target_id = "SecurityAlertsSnsRoot"
  arn       = aws_sns_topic.security_alerts.arn
}

resource "aws_cloudwatch_event_target" "critical_to_sns" {
  rule      = aws_cloudwatch_event_rule.critical_api_events.name
  target_id = "SecurityAlertsSnsCritical"
  arn       = aws_sns_topic.security_alerts.arn
}

resource "aws_sns_topic_policy" "allow_eventbridge" {
  arn = aws_sns_topic.security_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowEventBridgePublish"
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action   = "sns:Publish"
      Resource = aws_sns_topic.security_alerts.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = [
            aws_cloudwatch_event_rule.root_console_logins.arn,
            aws_cloudwatch_event_rule.critical_api_events.arn
          ]
        }
      }
    }]
  })
}
