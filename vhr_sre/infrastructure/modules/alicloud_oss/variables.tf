variable "environment" {
  description = "Deployment environment (dev, test, perf, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "perf", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, perf, staging, prod."
  }
}

variable "oss_allowed_origins" {
  description = "List of allowed origins for CORS on OSS bucket"
  type        = list(string)
  default     = ["*"]
}
