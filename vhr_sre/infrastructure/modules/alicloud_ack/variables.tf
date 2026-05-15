variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "vswitch_ids" {
  description = "List of vswitch IDs for primary cluster nodes"
  type        = list(string)
}

variable "dr_vswitch_ids" {
  description = "List of vswitch IDs for secondary cluster nodes (DR)"
  type        = list(string)
  default     = []
}

variable "security_group_id" {
  description = "Security group ID for cluster nodes"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.24"
}

variable "service_cidr" {
  description = "Service CIDR for primary cluster"
  type        = string
  default     = "172.19.0.0/20"
}

variable "pod_cidr" {
  description = "Pod CIDR for primary cluster"
  type        = string
  default     = "10.99.0.0/16"
}

variable "dr_service_cidr" {
  description = "Service CIDR for secondary cluster (DR)"
  type        = string
  default     = "172.20.0.0/20"
}

variable "dr_pod_cidr" {
  description = "Pod CIDR for secondary cluster (DR)"
  type        = string
  default     = "10.100.0.0/16"
}

variable "node_instance_types" {
  description = "Instance types for worker nodes"
  type        = list(string)
  default     = ["ecs.c6.large"]
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 2
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 10
}

variable "enable_autoscaling" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = true
}

variable "enable_dr" {
  description = "Enable disaster recovery (secondary cluster)"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = ""
}

variable "system_disk_size" {
  description = "System disk size in GB"
  type        = number
  default     = 100
}

variable "data_disk_size" {
  description = "Data disk size in GB"
  type        = number
  default     = 200
}

variable "user_data" {
  description = "User data script for node initialization"
  type        = string
  default     = ""
}

variable "node_labels" {
  description = "Labels to apply to worker nodes"
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "Taints to apply to worker nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "maintenance_time" {
  description = "Maintenance window start time (HH:MM:SS)"
  type        = string
  default     = "02:00:00"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
