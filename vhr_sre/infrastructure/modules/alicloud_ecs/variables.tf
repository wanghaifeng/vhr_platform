variable "environment" {
  description = "Deployment environment (dev, test, perf, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "perf", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, perf, staging, prod."
  }
}

variable "image_id" {
  description = "The ID of the ECS image to use"
  type        = string
}

variable "instance_type" {
  description = "Map of instance types for frontend and backend"
  type        = map(string)
  default = {
    frontend = "ecs.c6.large"
    backend  = "ecs.c6.large"
  }
}

variable "instance_counts" {
  description = "Map of instance counts for frontend and backend"
  type        = map(number)
  default = {
    frontend = 1
    backend  = 1
  }
}

variable "frontend_vswitch_id" {
  description = "The ID of the frontend VSwitch"
  type        = string
}

variable "backend_vswitch_id" {
  description = "The ID of the backend VSwitch"
  type        = string
}

variable "frontend_security_group_id" {
  description = "The ID of the security group for the frontend instances"
  type        = string
}

variable "backend_security_group_id" {
  description = "The ID of the security group for the backend instances"
  type        = string
}
