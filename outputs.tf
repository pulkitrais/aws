output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "web_instance_id" {
  description = "WebServer-01 instance ID"
  value       = module.compute.web_instance_id
}

output "sns_topic_arn" {
  description = "Security alerts SNS topic ARN"
  value       = module.automation.sns_topic_arn
}

output "cloudtrail_bucket_name" {
  description = "Audit logs bucket name"
  value       = module.monitoring.audit_logs_bucket_name
}
