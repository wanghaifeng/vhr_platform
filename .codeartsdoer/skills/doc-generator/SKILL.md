---
name: doc-generator
description: "Generate documentation from Terraform modules and Helm charts using terraform-docs. Triggers on: generate docs, update readme, terraform docs, module documentation."
---

# Doc Generator

Generate documentation from Terraform modules and Helm charts.

## The Job

1. Scan `modules/` and `helm/` directories
2. Generate `README.md` for each module/chart with inputs, outputs, usage. In English.
3. Save generated docs alongside the module

## Steps

### Step 1: Terraform Module Docs

For each module, generate README with:
- Module description
- Required and optional inputs (from variables.tf)
- Outputs (from outputs.tf)
- Example usage

### Step 2: Helm Chart Docs

For each chart, generate README with:
- Chart description (from Chart.yaml)
- Configuration options (from values.yaml)
- Installation commands per environment

## Configuration

| Setting | Value |
|---------|-------|
| Terraform Doc Tool | `terraform-docs` |
| Output Format | Markdown table |
| Output File | `README.md` |
