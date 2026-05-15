variable "namespace_name" {
  description = "ACR namespace name"
  type        = string
  default     = "vhr"
}

variable "visibility" {
  description = "Repository visibility: PUBLIC or PRIVATE"
  type        = string
  default     = "PRIVATE"
  validation {
    condition     = contains(["PUBLIC", "PRIVATE"], var.visibility)
    error_message = "Visibility must be PUBLIC or PRIVATE."
  }
}

variable "region" {
  description = "Alibaba Cloud region"
  type        = string
  default     = "cn-beijing"
}
