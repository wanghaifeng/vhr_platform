variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vswitch_id" {
  description = "VSwitch ID for the load balancer mappings"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for NLB mapping"
  type        = string
}

variable "address_type" {
  description = "Address type: Internet or Intranet"
  type        = string
  default     = "Internet"
}

variable "backend_server_ids" {
  description = "List of backend server IDs (ECS instances)"
  type        = list(string)
}

variable "backend_server_count" {
  description = "Number of backend servers (to avoid dynamic count errors)"
  type        = number
  default     = 0
}

variable "backend_port" {
  description = "Port used by Nginx Ingress Controller (e.g., 80 or NodePort)"
  type        = number
  default     = 80
}

variable "enable_https" {
  description = "Enable TCP 443 listener"
  type        = bool
  default     = false
}
