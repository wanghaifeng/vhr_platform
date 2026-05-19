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
  description = "The primary availability zone for the Redis instance"
  type        = string
}

variable "dr_availability_zone" {
  description = "The DR availability zone for the Redis standby instance (used for cross-AZ HA)"
  type        = string
  default     = ""
}

variable "dr_vswitch_id" {
  description = "The ID of the DR VSwitch for the Redis standby instance (used for cross-AZ HA)"
  type        = string
  default     = ""
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
  description = "Redis instance type (Redis or Memcache)"
  type        = string
  default     = "Redis"
}

variable "redis_instance_class" {
  description = "Redis instance class (e.g. redis.master.small.default for standard, redis.cluster.small.default for cluster)"
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

variable "enable_backup_log" {
  description = "Whether to enable log backup for the Redis instance (1 = enabled, 0 = disabled)"
  type        = number
  default     = 0
}
