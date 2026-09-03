# AWS Cloud Security Lab (Terraform) — Theory Documentation

## 1) Project Overview

The **AWS Cloud Security Lab** is a modular Terraform project that provisions a security-focused AWS environment in `eu-north-1`.
It demonstrates practical **defense-in-depth** across identity, network boundaries, compute access control, monitoring, and automated alerting.

This lab shows how AWS-native controls can be combined to support continuous monitoring, threat visibility, and faster incident response.

## 2) Architecture Overview

The root Terraform composes modules for:

- `modules/networking`: VPC, subnets, route controls, and network-level segmentation.
- `modules/compute`: EC2 deployment and security-group restrictions for controlled ingress.
- `modules/iam`: identity design using groups, policies, and an assumable security audit role.
- `modules/monitoring`: audit logging and telemetry foundations (`CloudTrail`, VPC flow logs, CloudWatch logs, protected S3 audit bucket).
- `modules/automation`: event routing and alert delivery using `EventBridge` and `SNS`.

Within a defense-in-depth model:

- **Preventive controls** reduce exposure before incidents occur (`IAM`, security groups, network segmentation).
- **Detective controls** capture and analyze activity (`CloudTrail`, flow logs, GuardDuty-compatible monitoring access).
- **Responsive controls** automate event routing and notification (`EventBridge` → `SNS`).

## 3) Security Controls – Theory & Implementation

### IAM (Least Privilege)

**Theory**

Least privilege means granting only the permissions required to perform a specific job function.
This limits blast radius if credentials are compromised and reduces accidental misuse of high-risk permissions.

**Implementation in this lab**

- Distinct IAM personas are provisioned:
  - `Developers` group with read-only access for selected services.
  - `Security` group with read-only visibility into monitoring and audit telemetry.
- A dedicated `SecurityAuditReadRole` is used for controlled access to audit data.
- Security users receive explicit `sts:AssumeRole` permissions for that audit role, instead of broad direct permissions.
- The monitoring policy intentionally focuses on read/list operations for `CloudTrail`, CloudWatch Logs, CloudWatch, and `GuardDuty`.

**Why this reduces attack surface**

- Shrinks over-permissioning risk.
- Enforces separation of duties between operators and security reviewers.
- Limits privilege escalation and lateral movement opportunities.

### AWS CloudTrail

**Theory**

`CloudTrail` records AWS API activity and account events, including identity context, event source, and action details.
It is central for accountability, forensic analysis, and compliance evidence.

**Implementation in this lab**

- A named `CloudTrail` trail is provisioned in the monitoring module.
- Management events are captured with read/write visibility.
- Logs are delivered to a dedicated S3 audit bucket.
- The audit bucket is hardened with:
  - versioning,
  - object lock (governance retention),
  - server-side encryption (`AES256`),
  - public-access blocking,
  - explicit policy permissions for the `cloudtrail.amazonaws.com` service principal.
- Log file validation is enabled to strengthen integrity checks.

**Why continuous audit logging is critical**

- Preserves evidence for incident response.
- Enables detection rules to trigger near-real-time alerts.
- Supports post-incident reconstruction and governance reporting.

### Amazon GuardDuty

**Theory**

`GuardDuty` is a managed threat detection service that analyzes telemetry and threat intelligence to surface suspicious behavior.
It helps detect compromise indicators such as anomalous API usage, reconnaissance, credential abuse, and known-malicious interactions.

**Implementation in this lab**

- The IAM monitoring model includes GuardDuty read/list permissions for the security function.
- The event-driven automation pattern in this lab (`EventBridge` + `SNS`) aligns with forwarding security findings for alerting.
- Operationally, GuardDuty findings can be routed through `EventBridge` rules (for `aws.guardduty` events) into the existing SNS alert pipeline.

> Note: This repository directly implements CloudTrail-based event detections and alerting, while maintaining an architecture compatible with GuardDuty finding integration.

### Amazon EventBridge

**Theory**

`EventBridge` acts as the event bus for matching high-value security signals and routing them to downstream responders.
It decouples detection logic from notification or remediation targets.

**Implementation in this lab**

- EventBridge rules are defined for high-risk events, including:
  - successful root account console sign-ins,
  - critical CloudTrail API actions such as IAM policy attachment, security-group rule modifications, and `StopLogging`.
- Matching events are sent to `SNS` targets.
- SNS topic policy allows publish access specifically from the configured EventBridge rules.

**Why this matters**

- Converts raw telemetry into actionable alerts.
- Reduces mean time to detect by automating routing.
- Standardizes security signal handling.

### Amazon SNS

**Theory**

`SNS` is a managed pub/sub notification service commonly used to fan out operational and security alerts.
It provides reliable delivery to subscribers such as email, endpoints, and downstream systems.

**Implementation in this lab**

- A dedicated `security-alerts` SNS topic is created.
- An email subscription is configured using the `alert_email` variable.
- EventBridge event targets publish matched security events to this topic.

**Why this matters**

- Ensures responders are notified quickly.
- Supports practical alert operations without custom messaging infrastructure.
- Keeps the alerting layer modular and extensible.

## 4) End-to-End Security Flow

1. Actions occur in the AWS account (console sign-ins, API calls, configuration changes).
2. `CloudTrail` records these events and writes immutable audit logs to the protected S3 bucket.
3. Event patterns are evaluated by `EventBridge` rules against high-signal security conditions.
4. Matching events are published to `SNS`.
5. `SNS` delivers notifications (email subscription) to security/operations stakeholders.

Pipeline summary:

- **Continuous monitoring data sources:** `CloudTrail` (and GuardDuty findings where integrated)
- **Routing/orchestration:** `EventBridge`
- **Automated alert delivery:** `SNS`

## 5) Defense-in-Depth Mapping

| Control | Layer Protected | Primary Security Objective |
|---|---|---|
| `IAM` least-privilege groups and role design | Identity & Access | Minimize unauthorized/over-privileged access |
| `CloudTrail` + hardened audit S3 bucket | Audit & Detection | Capture, preserve, and validate account/API activity |
| `GuardDuty` access model + event integration path | Threat Detection | Surface suspicious or malicious behavior indicators |
| `EventBridge` rule engine | Detection Orchestration | Transform security events into actionable signals |
| `SNS` topic and subscriptions | Response & Alerting | Deliver timely notifications for investigation/action |

## 6) Key Takeaways / Learning Outcomes

After reviewing this lab, readers should understand how to:

- implement least-privilege identity patterns with IAM groups, policies, and controlled role assumption;
- establish durable audit logging with `CloudTrail` and protected S3 storage controls;
- design an event-driven detection pipeline with `EventBridge` and `SNS`;
- map security controls to preventive, detective, and responsive layers in a defense-in-depth strategy;
- communicate practical cloud security architecture in a way aligned with real operational monitoring workflows.
