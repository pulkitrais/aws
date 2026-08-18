variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-north-1"
}

variable "admin_ingress_cidr" {
  description = "CIDR block allowed to SSH into WebServer-01"
  type        = string
}

variable "alert_email" {
  description = "Email endpoint to subscribe to SNS security alerts"
  type        = string
}

variable "audit_logs_bucket_name" {
  description = "Unique S3 bucket name for CloudTrail audit logs"
  type        = string
}
