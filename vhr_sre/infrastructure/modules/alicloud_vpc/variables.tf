variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "frontend_cidr" {
  description = "CIDR for frontend subnet (Node.js)"
  type        = string
}

variable "backend_cidr" {
  description = "CIDR for backend subnet (RabbitMQ/Services)"
  type        = string
}

variable "db_cidr" {
  description = "CIDR for database subnet (MySQL/Redis)"
  type        = string
}

variable "dr_cidr" {
  description = "CIDR for disaster recovery subnet"
  type        = string
  default     = ""
}

variable "allowed_db_ports" {
  description = "List of ports allowed for database security group"
  type        = list(string)
  default     = ["3306", "6379", "5672"]
}

variable "environment" {
  description = "Deployment environment (dev, test, perf, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "perf", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, perf, staging, prod."
  }
}
