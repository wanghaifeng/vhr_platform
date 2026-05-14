# VHR SRE Configuration Guide

This repository contains the Infrastructure as Code (Terraform), CI/CD pipelines, and Policy as Code (OPA) configurations for the VHR application.

---

## 0. Prerequisites - Credential Setup

Before running Terraform, you must configure the following credentials:

### Alibaba Cloud Access Key (AKSK)

**Option 1: Using Alibaba Cloud CLI (Recommended)**
```bash
aliyun configure
# Follow prompts to enter AccessKey ID and AccessKey Secret
```

**Option 2: Using Environment Variables (Linux/macOS)**
```bash
export ALICLOUD_ACCESS_KEY="your-access-key-id"
export ALICLOUD_SECRET_KEY="your-access-key-secret"
```

**Option 3: Using Environment Variables (Windows CMD)**
```cmd
set ALICLOUD_ACCESS_KEY=your-access-key-id
set ALICLOUD_SECRET_KEY=your-access-key-secret
```

**Option 4: Using Environment Variables (Windows PowerShell)**
```powershell
$env:ALICLOUD_ACCESS_KEY = "your-access-key-id"
$env:ALICLOUD_SECRET_KEY = "your-access-key-secret"
```

**Option 5: System Environment Variables (Windows - Permanent)**
```cmd
setx ALICLOUD_ACCESS_KEY "your-access-key-id"
setx ALICLOUD_SECRET_KEY "your-access-key-secret"
```
> Note: After using `setx`, restart your terminal for changes to take effect.

### MySQL and Redis Passwords

Terraform requires MySQL root password and Redis password. Set them via environment variables:

**Linux/macOS:**
```bash
export TF_VAR_mysql_root_password="your-mysql-password"
export TF_VAR_redis_password="your-redis-password"
```

**Windows CMD:**
```cmd
set TF_VAR_mysql_root_password=your-mysql-password
set TF_VAR_redis_password=your-redis-password
```

**Windows PowerShell:**
```powershell
$env:TF_VAR_mysql_root_password = "your-mysql-password"
$env:TF_VAR_redis_password = "your-redis-password"
```

> ⚠️ **Security Note**: Never commit passwords to version control. Use environment variables or secret management tools in CI/CD pipelines.

---

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
- `.harness/infra-deploy.yaml`: This single pipeline now supports all five environments (`dev`, `test`, `staging`, `perf`, `prod`). It uses a pipeline variable named `environment` which you select at runtime. The pipeline dynamically changes directory to `vhr_sre/infrastructure`, sets Alicloud Access Key and Secret Key as environment variables, and then executes Terraform commands using `-chdir` to the specific environment's subdirectory.
- `.harness/service-deploy.yaml`: Pipeline for application service deployments.

**Variables Setup (Harness):**
1. **Alicloud Credentials**: Define `alicloud_access_key` and `alicloud_secret_key` as **Harness Secrets** (scoped to project or organization level for reusability). These are then exposed as environment variables in the pipeline steps using `export ALICLOUD_ACCESS_KEY=<+secrets.getValue("alicloud_access_key")>` and `export ALICLOUD_SECRET_KEY=<+secrets.getValue("alicloud_secret_key")>`.
2. **Environments**: In the Harness UI, go to **Environments** and define the 5 environments (`dev`, `test`, `staging`, `perf`, `prod`).
3. **Environment Variables**: Add environment-specific variables (e.g., database host, API endpoints) using the **Environment Variables** overrides section within each Harness Environment.
4. **Sensitive Data (Terraform)**: For Terraform variables like `mysql_root_password` and `redis_password`, define them as **Harness Secrets** (e.g., `mysql_root_password`, `redis_password`) and reference them in the `terraform plan` command using `-var="variable_name=<+secrets.getValue("secret_identifier")>"`.
5. When running the `infra-deploy.yaml` pipeline, you will be prompted to select the target `environment` via the pipeline variable.

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
