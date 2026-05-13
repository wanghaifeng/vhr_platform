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
  description = "The availability zone for the RDS instance"
  type        = string
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
