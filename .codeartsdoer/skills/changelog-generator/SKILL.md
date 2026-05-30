---
name: changelog-generator
description: "Generate CHANGELOG.md from git commit history using Conventional Commits. Triggers on: changelog, release notes, version history, generate changelog."
---

# Changelog Generator

Generate CHANGELOG.md from git commit history.

## The Job

1. Parse git log for Conventional Commits
2. Group by type: Added (feat), Changed (refactor), Fixed (fix), Docs (docs)
3. Write CHANGELOG.md with version sections

## Commit Format

```
<type>(<scope>): <subject>

Types: feat, fix, docs, refactor, test, chore
Scopes: infra, helm, docs, backend, frontend
```

## Output Format

```markdown
## [v1.3.0] - 2026-05-30

### Added
- feat(infra): enable Istio service mesh on prod and staging

### Fixed
- fix(helm): correct VirtualService weight for canary
```

## Configuration

| Setting | Value |
|---------|-------|
| Changelog File | `CHANGELOG.md` |
| Commit Format | Conventional Commits |
| Max Versions | 10 |
| Date Format | YYYY-MM-DD |
