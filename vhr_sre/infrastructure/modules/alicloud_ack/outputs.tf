# Primary Cluster Outputs
output "primary_cluster_id" {
  description = "Primary cluster ID"
  value       = alicloud_cs_managed_kubernetes.primary.id
}

output "primary_cluster_name" {
  description = "Primary cluster name"
  value       = alicloud_cs_managed_kubernetes.primary.name
}

output "primary_cluster_endpoint" {
  description = "Primary cluster API endpoint"
  value       = alicloud_cs_managed_kubernetes.primary.connections.api_server_internet_endpoint
}

output "primary_cluster_version" {
  description = "Primary cluster Kubernetes version"
  value       = alicloud_cs_managed_kubernetes.primary.version
}

output "primary_worker_role_arn" {
  description = "Primary cluster worker role ARN"
  value       = alicloud_cs_managed_kubernetes.primary.worker_ram_role_name
}

output "primary_security_group_id" {
  description = "Primary cluster security group ID"
  value       = alicloud_cs_managed_kubernetes.primary.security_group_id
}

# Secondary Cluster Outputs (DR)
output "secondary_cluster_id" {
  description = "Secondary cluster ID (DR)"
  value       = var.enable_dr ? alicloud_cs_managed_kubernetes.secondary[0].id : ""
}

output "secondary_cluster_name" {
  description = "Secondary cluster name (DR)"
  value       = var.enable_dr ? alicloud_cs_managed_kubernetes.secondary[0].name : ""
}

output "secondary_cluster_endpoint" {
  description = "Secondary cluster API endpoint (DR)"
  value       = var.enable_dr ? alicloud_cs_managed_kubernetes.secondary[0].connections.api_server_internet_endpoint : ""
}

output "secondary_cluster_version" {
  description = "Secondary cluster Kubernetes version (DR)"
  value       = var.enable_dr ? alicloud_cs_managed_kubernetes.secondary[0].version : ""
}

# Node Pool Outputs
output "primary_node_pool_id" {
  description = "Primary cluster node pool ID"
  value       = alicloud_cs_kubernetes_node_pool.primary_workers.id
}

output "secondary_node_pool_id" {
  description = "Secondary cluster node pool ID (DR)"
  value       = var.enable_dr ? alicloud_cs_kubernetes_node_pool.secondary_workers[0].id : ""
}

# DR Status
output "dr_enabled" {
  description = "Disaster recovery enabled status"
  value       = var.enable_dr
}

# Cluster Summary
output "clusters" {
  description = "Summary of all clusters"
  value = {
    primary = {
      id        = alicloud_cs_managed_kubernetes.primary.id
      name      = alicloud_cs_managed_kubernetes.primary.name
      endpoint  = alicloud_cs_managed_kubernetes.primary.connections.api_server_internet_endpoint
      version   = alicloud_cs_managed_kubernetes.primary.version
      node_pool = alicloud_cs_kubernetes_node_pool.primary_workers.id
    }
    secondary = var.enable_dr ? {
      id        = alicloud_cs_managed_kubernetes.secondary[0].id
      name      = alicloud_cs_managed_kubernetes.secondary[0].name
      endpoint  = alicloud_cs_managed_kubernetes.secondary[0].connections.api_server_internet_endpoint
      version   = alicloud_cs_managed_kubernetes.secondary[0].version
      node_pool = alicloud_cs_kubernetes_node_pool.secondary_workers[0].id
    } : null
  }
}
