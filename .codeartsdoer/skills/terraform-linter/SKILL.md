---
name: terraform-linter
description: "Run Terraform fmt, validate, and tflint before committing .tf files. Triggers on: terraform validation, tf lint, terraform check, validate terraform, terraform fmt."
---

# Terraform Linter

Automatically validate Terraform code quality before committing `.tf` files.

## The Job

1. Detect `.tf` file changes in the commit
2. Run format check → validation → lint
3. Block commit if any check fails; suggest fixes

## Steps

### Step 1: Format Check

```bash
cd vhr_sre/infrastructure
terraform fmt -recursive -check
```

If fails, auto-fix with: `terraform fmt -recursive`

### Step 2: Validation

```bash
terraform init -backend=false
terraform validate
```

Must return `Success!`

### Step 3: Lint

```bash
tflint --recursive
```

Checks: unused variables, deprecated syntax, naming conventions, missing descriptions.

## Configuration

| Setting | Value |
|---------|-------|
| Working Directory | `vhr_sre/infrastructure` |
| Terraform Version | `>= 1.6.0` |
| TFLint Version | `v0.52.0` |
| Auto-fix | Yes (fmt only) |
| Block Commit on Failure | Yes |
