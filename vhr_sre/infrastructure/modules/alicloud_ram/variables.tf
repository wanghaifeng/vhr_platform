variable "environment" {
  description = "Deployment environment (dev, test, perf, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "perf", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, perf, staging, prod."
  }
}

variable "project_name" {
  description = "Project name used as prefix for RAM resource naming"
  type        = string
  default     = "vhr"
}

variable "region" {
  description = "AliCloud region for resource scope in policies"
  type        = string
  default     = "cn-beijing"
}

variable "vpc_id" {
  description = "VPC ID for environment-scoped policy conditions"
  type        = string
}

variable "create_ci_user" {
  description = "Create a CI/CD RAM user with AKSK for this environment"
  type        = bool
  default     = true
}

variable "ci_user_name" {
  description = "Name for the CI/CD RAM user (defaults to vhr-ci-{env})"
  type        = string
  default     = ""
}

variable "create_readonly_user" {
  description = "Create a read-only RAM user for this environment (for auditors/ops)"
  type        = bool
  default     = false
}

variable "readonly_user_name" {
  description = "Name for the read-only RAM user (defaults to vhr-readonly-{env})"
  type        = string
  default     = ""
}

variable "environment_admin_ram_role_name" {
  description = "Name for the environment admin RAM role (for assume-role access)"
  type        = string
  default     = ""
}

variable "create_ack_worker_policy" {
  description = "Create a scoped policy for ACK worker nodes and attach to the specified RAM role"
  type        = bool
  default     = false
}

variable "ack_worker_ram_role_name" {
  description = "ACK cluster worker RAM role name to attach the scoped policy to (required when create_ack_worker_policy = true)"
  type        = string
  default     = ""
}

variable "allowed_actions" {
  description = "List of action patterns allowed for CI/CD user in this environment"
  type        = list(string)
  default     = []
}

variable "deny_actions" {
  description = "List of action patterns explicitly denied for this environment"
  type        = list(string)
  default     = []
}
