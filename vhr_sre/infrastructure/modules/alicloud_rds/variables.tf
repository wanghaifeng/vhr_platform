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
  description = "The primary availability zone for the RDS instance"
  type        = string
}

variable "dr_availability_zone" {
  description = "The DR availability zone for the RDS standby instance (used when category is HighAvailability)"
  type        = string
  default     = ""
}

variable "dr_vswitch_id" {
  description = "The ID of the DR VSwitch for the RDS standby instance (used when category is HighAvailability)"
  type        = string
  default     = ""
}

variable "category" {
  description = "RDS instance category: Basic (single node), HighAvailability (dual node with auto-failover), AlwaysOn (triple node cluster)"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "HighAvailability", "AlwaysOn"], var.category)
    error_message = "Category must be one of: Basic, HighAvailability, AlwaysOn."
  }
}

variable "security_ip_list" {
  description = "List of IP addresses allowed to connect to RDS"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "mysql_version" {
  description = "MySQL engine version"
  type        = string
  default     = "5.7"
}

variable "mysql_instance_type" {
  description = "RDS instance type"
  type        = string
  default     = "rds.mysql.s2.large"
}

variable "mysql_instance_storage" {
  description = "RDS instance storage in GB"
  type        = number
  default     = 20
}

variable "mysql_root_username" {
  description = "Root username for MySQL"
  type        = string
  default     = "root"
}

variable "mysql_root_password" {
  description = "Root password for MySQL"
  type        = string
  sensitive   = true
}

variable "backup_period" {
  description = "Backup period, e.g. [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]"
  type        = set(string)
  default     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
}

variable "backup_time" {
  description = "Backup start time window in UTC, e.g. 02:00Z-03:00Z"
  type        = string
  default     = "02:00Z-03:00Z"
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "enable_backup_log" {
  description = "Whether to enable log backup"
  type        = bool
  default     = false
}

variable "log_backup_retention_period" {
  description = "Number of days to retain log backups"
  type        = number
  default     = 7
}
