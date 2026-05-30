---
name: helm-linter
description: "Validate Helm charts with lint and template rendering. Triggers on: helm lint, helm validate, helm check, chart validation."
---

# Helm Linter

Validate Helm charts before committing.

## The Job

1. Detect `helm/` file changes
2. Run `helm lint` for each chart
3. Run `helm template` for each environment
4. Block commit if any check fails

## Steps

### Step 1: Lint

```bash
helm lint helm/vhr-frontend
helm lint helm/argo-rollouts
helm lint helm/monitoring
```

### Step 2: Template Render

```bash
for env in dev test staging prod; do
  helm template vhr-frontend ./helm/vhr-frontend \
    -f ./helm/vhr-frontend/values-$env.yaml \
    --namespace vhr-$env > /dev/null
done
```

Catches: undefined values, invalid conditionals, template syntax errors.

## Configuration

| Setting | Value |
|---------|-------|
| Helm Version | `v3.15.0+` |
| Charts Directory | `helm/` |
| Environments | `dev, test, staging, perf, prod` |
| Block Commit on Failure | Yes |
