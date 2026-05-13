variable "environment" {
  description = "Deployment environment (dev, test, perf, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "perf", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, perf, staging, prod."
  }
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "db_vswitch_id" {
  description = "The ID of the database VSwitch"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the Redis instance"
  type        = string
}

variable "security_ip_list" {
  description = "List of IP addresses allowed to connect to Redis"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "redis_version" {
  description = "Redis engine version"
  type        = string
  default     = "5.0"
}

variable "redis_instance_type" {
  description = "Redis instance type"
  type        = string
  default     = "redis.master.small.default"
}

variable "redis_instance_storage" {
  description = "Redis instance storage in GB"
  type        = number
  default     = 20
}

variable "redis_password" {
  description = "Password for Redis instance"
  type        = string
  sensitive   = true
  default     = ""
}
