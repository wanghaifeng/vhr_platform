variable "project_name" {
  type    = string
  default = "vhr"
}

variable "environment" {
  type    = string
  default = "staging"
  validation {
    condition     = contains(["staging"], var.environment)
    error_message = "Environment must be &#39;staging&#39;."
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

variable "ssl_certificate_id" {
  description = "SSL certificate ID for HTTPS listener"
  type        = string
  default     = ""
}

variable "enable_ssl_at_nlb" {
  description = "Enable SSL termination at NLB (TCPSSL). If false, SSL termination is at Ingress Controller."
  type        = bool
  default     = false
}

variable "allowed_external_cidrs" {
  description = "List of external CIDR blocks allowed to access staging (e.g., partner/external team IPs for UAT)"
  type        = list(string)
  default     = []
}

variable "staging_domain" {
  description = "Staging UAT domain name (e.g., vhr-staging). Leave empty to skip DNS record creation."
  type        = string
  default     = ""
}

variable "staging_domain_subdomain" {
  description = "Subdomain prefix for staging UAT DNS record (e.g., vhr-staging)"
  type        = string
  default     = "vhr-staging"
}

variable "staging_api_subdomain" {
  description = "Subdomain prefix for staging API DNS record (e.g., api-vhr-staging). Leave empty to skip."
  type        = string
  default     = ""
}

variable "dns_domain_name" {
  description = "Base DNS domain name for staging records (e.g., example.com)"
  type        = string
  default     = ""
}
