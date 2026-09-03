# AWS Cloud Security Lab (Terraform)

This repository provisions a modular AWS Cloud Security Lab in **eu-north-1** demonstrating defense-in-depth across networking, compute hardening, IAM, monitoring/logging, and alert automation.

## Structure

- `main.tf` - root composition of modules
- `variables.tf` - root input variables
- `outputs.tf` - root outputs
- `versions.tf` - Terraform/provider requirements
- `modules/networking` - VPC, subnets, IGW, routes, NACL, ENI
- `modules/compute` - Web-SG and `WebServer-01` EC2 deployment
- `modules/iam` - Admin programmatic user, Developers and Security IAM groups
- `modules/monitoring` - VPC Flow Logs, CloudWatch logs, S3 Audit bucket, CloudTrail
- `modules/automation` - SNS alerts, email subscription, EventBridge rules/targets

## Inputs

Copy `terraform.tfvars.example` to `terraform.tfvars` and update values:

- `admin_ingress_cidr` - CIDR allowed for SSH to WebServer-01
- `alert_email` - SNS alert subscription email
- `audit_logs_bucket_name` - globally unique S3 bucket for audit logs

## Usage

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

## Theory Documentation

- See `THEORY.md` for a complete security theory and implementation walkthrough covering `IAM`, `CloudTrail`, `GuardDuty`, `EventBridge`, and `SNS`.

## Security Notes

- Audit logs bucket uses Object Lock (WORM), versioning, SSE-S3 encryption, and public access blocking.
- CloudTrail writes are restricted to the CloudTrail service.
- Security team members in the `Security` IAM group can assume `SecurityAuditReadRole` to read audit logs.
