---
name: terraform-security-scanner
description: "Scan Terraform code for security vulnerabilities using tfsec. Triggers on: security scan, tfsec, terraform security, check security, scan secrets."
---

# Terraform Security Scanner

Scan Terraform code for security vulnerabilities before committing.

## The Job

1. Detect `.tf` file changes
2. Run `tfsec` to find security issues
3. Block commit on CRITICAL or HIGH findings

## Steps

### Step 1: Run tfsec

```bash
cd vhr_sre/infrastructure
tfsec .
```

### Step 2: Review Findings

Key rules checked:

| Rule | Description | Severity |
|------|-------------|----------|
| Public resource exposure | S3/NLB/RDS publicly accessible | CRITICAL |
| Open security group | 0.0.0.0/0 ingress, especially port 22 | CRITICAL/HIGH |
| Missing encryption | RDS/OSS without encryption at rest | HIGH |
| Missing backup | RDS without backup configured | HIGH |
| Hardcoded secrets | Secrets in plaintext | CRITICAL |

### Step 3: Fix or Suppress

Fix the issue, or suppress with annotation:
```hcl
# tfsec:ignore:AWS018
```

## Configuration

| Setting | Value |
|---------|-------|
| Working Directory | `vhr_sre/infrastructure` |
| Scanner | `tfsec` |
| Soft Fail | No (blocks commit on CRITICAL/HIGH) |
| Minimum Severity | MEDIUM |
