data "aws_caller_identity" "current" {}

resource "aws_iam_user" "admin_programmatic" {
  name = "admin-programmatic"

  tags = {
    Name = "admin-programmatic"
  }
}

resource "aws_iam_user_policy_attachment" "admin_access" {
  user       = aws_iam_user.admin_programmatic.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy_attachment" "developers_ec2_readonly" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "developers_s3_readonly" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_group" "security" {
  name = "Security"
}

resource "aws_iam_policy" "security_readonly_monitoring" {
  name        = "SecurityReadOnlyMonitoring"
  description = "Read-only CloudTrail/CloudWatch/GuardDuty access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudtrail:Describe*",
          "cloudtrail:Get*",
          "cloudtrail:List*",
          "logs:Describe*",
          "logs:Get*",
          "logs:FilterLogEvents",
          "cloudwatch:Describe*",
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "guardduty:Get*",
          "guardduty:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "security_monitoring_readonly" {
  group      = aws_iam_group.security.name
  policy_arn = aws_iam_policy.security_readonly_monitoring.arn
}

resource "aws_iam_role" "security_audit_read_role" {
  name = "SecurityAuditReadRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_group_policy" "security_assume_audit_read_role" {
  name  = "SecurityAssumeAuditReadRole"
  group = aws_iam_group.security.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = aws_iam_role.security_audit_read_role.arn
    }]
  })
}
