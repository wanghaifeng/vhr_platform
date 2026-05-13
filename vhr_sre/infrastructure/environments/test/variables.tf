variable "project_name" {
  type    = string
  default = "vhr"
}

variable "environment" {
  type    = string
  default = "test"
  validation {
    condition     = contains(["test"], var.environment)
    error_message = "Environment must be &#39;test&#39;."
  }
}

variable "region" {
  type    = string
  default = "cn-beijing"
}

variable "ecs_image_id" {
  description = "The ID of the ECS image to use"
  type        = string
  default     = "m-bp107p80w3p52v121h8x" # Example image ID, replace with actual
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
  default     = ""
}

variable "oss_allowed_origins" {
  description = "List of allowed origins for CORS on OSS bucket"
  type        = list(string)
  default     = ["*"]
}
