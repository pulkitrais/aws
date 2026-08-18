output "security_iam_group_arn" {
  value = aws_iam_group.security.arn
}

output "security_iam_group_name" {
  value = aws_iam_group.security.name
}

output "security_audit_read_role_arn" {
  value = aws_iam_role.security_audit_read_role.arn
}
