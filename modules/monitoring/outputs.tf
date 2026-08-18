output "audit_logs_bucket_name" {
  value = aws_s3_bucket.audit_logs.id
}

output "cloudtrail_arn" {
  value = aws_cloudtrail.this.arn
}
