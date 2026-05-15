variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vswitch_id" {
  description = "VSwitch ID for the load balancer"
  type        = string
}

variable "slb_spec" {
  description = "SLB specification type"
  type        = string
  default     = "slb.s1.small"
}

variable "address_type" {
  description = "Address type: internet or intranet"
  type        = string
  default     = "internet"
}

variable "internet_charge_type" {
  description = "Internet charge type: paybytraffic or paybybandwidth"
  type        = string
  default     = "paybytraffic"
}

variable "backend_port" {
  description = "Backend server port"
  type        = number
  default     = 8080
}

variable "backend_server_ids" {
  description = "List of backend ECS instance IDs"
  type        = list(string)
}

variable "server_weight" {
  description = "Weight for backend servers"
  type        = number
  default     = 100
}

variable "health_check_uri" {
  description = "Health check URI path"
  type        = string
  default     = "/health"
}

variable "health_check_domain" {
  description = "Health check domain"
  type        = string
  default     = ""
}

variable "enable_sticky_session" {
  description = "Enable sticky session"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "ssl_certificate_id" {
  description = "SSL certificate ID for HTTPS"
  type        = string
  default     = ""
}
