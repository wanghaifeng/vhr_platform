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
  description = "List of backend server IDs (ECS instances or ACK nodes)"
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
  description = "Enable TCP 443 listener (SSL termination handled by Ingress Controller)"
  type        = bool
  default     = false
}

variable "ssl_certificate_id" {
  description = "SSL certificate ID for TCPSSL listener (optional, use if NLB should terminate SSL)"
  type        = string
  default     = ""
}

variable "enable_ssl_at_nlb" {
  description = "Enable SSL termination at NLB (TCPSSL). If false, SSL termination is at Ingress Controller."
  type        = bool
  default     = false
}
