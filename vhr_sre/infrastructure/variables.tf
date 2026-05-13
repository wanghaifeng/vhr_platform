variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, perf, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "perf", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, perf, staging, prod."
  }
}

variable "ecs_image_id" {
  description = "The ID of the ECS image to use"
  type        = string
}

variable "oss_allowed_origins" {
  description = "List of allowed origins for CORS on OSS bucket"
  type        = list(string)
  default     = []
}

variable "mysql_root_password" {
  description = "Root password for MySQL"
  type        = string
  sensitive   = true
}

variable "redis_password" {
  description = "Password for Redis instance"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AliCloud region to deploy resources"
  type        = string
  default     = "cn-beijing"
}
