---
name: git-hooks-manager
description: "Manage pre-commit hooks for local Terraform and Helm validation. Triggers on: install hooks, setup pre-commit, git hooks, pre-commit install."
---

# Git Hooks Manager

Manage pre-commit hooks for local validation before commit/push.

## The Job

1. Install pre-commit hooks that run terraform/helm validation
2. Install pre-push hook that warns on direct push to main
3. Ensure hooks are executable

## Hooks

### pre-commit

Runs before `git commit`:
- `.tf` files changed → `terraform fmt -check` + `validate` + `tflint`
- `helm/` files changed → `helm lint`
- All commits → `gitleaks` secret scan

### pre-push

Runs before `git push`:
- Warns if pushing directly to `main` or `master`

## Installation

```bash
pip install pre-commit
pre-commit install
```

## Configuration

| Setting | Value |
|---------|-------|
| Pre-commit Config | `.pre-commit-config.yaml` |
| Auto-install on Clone | Yes |
