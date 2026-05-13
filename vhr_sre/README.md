# VHR SRE Configuration Guide

This repository contains the Infrastructure as Code (Terraform), CI/CD pipelines, and Policy as Code (OPA) configurations for the VHR application.

## 1. CI/CD Pipelines Setup (GitHub Actions & Harness)

### GitHub Actions (Continuous Integration)
We use GitHub Actions to build our services and validate our infrastructure.

**Files:**
- `.github/workflows/service-ci.yaml`: Builds the Spring Boot backend and Vue.js frontend on push/PR to the application codebase.
- `.github/workflows/terraform-ci.yaml`: Runs `terraform fmt`, `init`, `validate`, and `test` on push/PR to the `vhr_sre/infrastructure` codebase.

**Variables Setup (Environments):**
To manage the 5 environments (`dev`, `test`, `staging`, `perf`, `prod`):
1. Go to your GitHub repository **Settings > Environments**.
2. Create the five environments.
3. Add any required secrets (e.g., `MYSQL_PASSWORD`) or variables (e.g., `APP_ENV`) inside each environment.
4. Update the GitHub workflows to reference the environments when needed (e.g., `environment: dev`).

### Harness (Continuous Deployment)
We use Harness for deploying infrastructure and application services securely.

**Files:**
- `.harness/infra-deploy.yaml`: Pipeline for Terraform infrastructure deployments. Includes manual approval before `terraform apply`.
- `.harness/service-deploy.yaml`: Pipeline for application service deployments.

**Variables Setup:**
1. In the Harness UI, go to **Environments** and define the 5 environments (`dev`, `test`, `staging`, `perf`, `prod`).
2. Add environment-specific variables using the **Environment Variables** overrides section.
3. Pass the target environment dynamically when triggering the pipeline using Pipeline Variables.

---

## 2. Policy as Code Setup (OPA / Harness Policies)

To ensure security and compliance, we use Harness Policy as Code powered by OPA (Open Policy Agent).

**Policy Files:**
- `.harness/policies/approval_for_prod.rego`: Enforces that any pipeline modifying `staging` or `production` environments MUST include a manual approval step (`HarnessApproval`).
- `.harness/policies/secret_scanning_required.rego`: Enforces that every pipeline MUST include a secret scanning step (like `gitleaks` or `trivy`) to prevent hardcoded credentials.

**Setup Instructions in Harness:**
1. In your Harness Account/Project, navigate to **Project Setup > Policies**.
2. Click **New Policy** and import/paste the contents of `approval_for_prod.rego`. Name it "Enforce Prod Approval".
3. Click **New Policy** again and import/paste the contents of `secret_scanning_required.rego`. Name it "Enforce Secret Scanning".
4. Navigate to **Policy Sets**.
5. Create a new Policy Set that includes both policies.
6. Configure the Policy Set to trigger on the **On Save** or **On Run** pipeline events.
7. Set the action to **Error and Exit** to ensure developers cannot save or execute non-compliant pipelines.
