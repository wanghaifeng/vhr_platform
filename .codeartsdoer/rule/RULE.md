---
name: vhr-project-rules
description: "VHR project coding standards and validation rules. Enforces Terraform fmt/validate/tflint, Helm lint, security scanning, and conventional commits before every commit."
---

# VHR Project Rules

Coding standards, validation rules, and best practices for the VHR project. All rules are enforced both locally (via skills) and in CI (via GitHub Actions).

---

## The Job

When modifying code in this project, follow these rules BEFORE committing:

1. If `.tf` files changed → run Terraform validation
2. If `helm/` files changed → run Helm validation
3. Always → check for secrets, follow commit format

---

## Rule 1: Terraform Pre-Commit Validation

When `.tf` files are modified, ALL of the following MUST pass before commit:

```bash
terraform fmt -recursive -check   # Format check (fix with: terraform fmt -recursive)
terraform validate                # Must return: "Success!"
tflint --recursive               # Must return: "No issues found"
```

Working directory: `vhr_sre/infrastructure`

## Rule 2: Terraform Naming

| Element | Convention | Example |
|---------|------------|---------|
| Resource names | `{env}-{project}-{role}` | `prod-vhr-mysql` |
| Variables | `snake_case` | `node_instance_types` |
| Outputs | `{resource}_{attribute}` | `primary_cluster_endpoint` |
| Modules | `alicloud_{service}` | `alicloud_ack` |
| Files | `{type}.tf` | `main.tf`, `variables.tf`, `outputs.tf` |

## Rule 3: Terraform Required Attributes

- Every variable MUST have `description` + `type` (+ `default` if optional)
- Sensitive variables MUST have `sensitive = true` with NO hardcoded defaults
- Every output MUST have `description`

## Rule 4: Terraform Module Structure

```
modules/{name}/
├── main.tf        # Resource definitions
├── variables.tf   # Input variables (with descriptions)
└── outputs.tf     # Output values (with descriptions)
```

## Rule 5: Terraform Best Practices

- Use `for_each` over `count` for multiple similar resources
- Use `dynamic` blocks for optional nested configurations
- Use `locals` for computed values
- Use `data` sources instead of hardcoding IDs
- Add `lifecycle { prevent_destroy = true }` for production resources

## Rule 6: Helm Pre-Commit Validation

When `helm/` files are modified:

```bash
helm lint <chart-dir>                                    # Must pass
helm template <release> <chart> -f values-<env>.yaml     # Must render for all envs
```

## Rule 7: Helm Best Practices

- Use `{{ include "chart.fullname" . }}` for naming
- Use `{{- define }}` in `_helpers.tpl` for reusable templates
- Guard optional resources with `{{- if .Values.x.enabled }}`
- Set resource limits for all containers
- Define `livenessProbe` and `readinessProbe`

## Rule 8: Commit Message Format

Conventional Commits ONLY:

```
<type>(<scope>): <subject>
```

- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- **Scopes**: `infra`, `helm`, `docs`, `backend`, `frontend`

Examples:
```
feat(infra): enable Istio service mesh on prod and staging
fix(helm): correct VirtualService weight for canary
docs(infra): update RDS HA configuration
```

## Rule 9: Security — NEVER Commit

- `*.tfstate`, `*.tfstate.backup`, `.terraform/`
- `*.pem`, `*.key`, `*.p12`
- `.env`, `.env.local`, `.env.production`
- Any file with passwords, API keys, or tokens

## Rule 10: Secret Management

- Use `sensitive = true` for all secret Terraform variables
- Pass secrets via `TF_VAR_*` environment variables
- Use Alibaba Cloud KMS for encryption
- NEVER log or output sensitive values

## Rule 11: Documentation Sync

Update docs when infrastructure changes:
- `docs/infrastructure-overview.md` — component changes
- `docs/operations-manual.md` — procedure changes
- `docs/progressive-delivery/` — deployment strategy changes

## Rule 12: Pre-Merge Testing

Before merging to main:

```bash
# Terraform
cd vhr_sre/infrastructure && terraform test

# Helm (all environments)
for env in dev test staging prod; do
  helm template vhr-frontend ./helm/vhr-frontend \
    -f ./helm/vhr-frontend/values-$env.yaml --namespace vhr-$env > /dev/null
done
```
