output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "backend_instance_ids" {
  description = "List of backend ECS instance IDs"
  value       = module.ecs.backend_instance_ids
}

output "rds_connection_string" {
  description = "The connection string of the RDS instance"
  value       = module.rds.rds_connection_string
}

output "redis_connection_string" {
  description = "The connection string of the Redis instance"
  value       = module.kvstore.redis_connection_string
}

output "oss_bucket_name" {
  description = "The name of the OSS bucket"
  value       = module.oss.oss_bucket_name
}

output "nlb_dns_name" {
  description = "The DNS name of the NLB"
  value       = module.nlb.nlb_dns_name
}

output "nlb_id" {
  description = "The ID of the NLB instance"
  value       = module.nlb.nlb_id
}

# Kubernetes outputs
output "k8s_cluster_id" {
  description = "Kubernetes cluster ID"
  value       = module.ack.primary_cluster_id
}

output "k8s_cluster_endpoint" {
  description = "Kubernetes cluster API endpoint"
  value       = module.ack.primary_cluster_endpoint
}

# Staging-specific outputs for external integration
output "staging_uat_fqdn" {
  description = "Staging UAT fully qualified domain name"
  value       = var.staging_domain != "" ? "${var.staging_domain_subdomain}.${var.dns_domain_name}" : ""
}

output "staging_api_fqdn" {
  description = "Staging API fully qualified domain name"
  value       = var.staging_api_subdomain != "" ? "${var.staging_api_subdomain}.${var.dns_domain_name}" : ""
}

output "allowed_external_cidrs" {
  description = "External CIDRs allowed to access staging"
  value       = var.allowed_external_cidrs
}

# RAM outputs
output "ram_ci_user_name" {
  description = "CI/CD RAM user name for this environment"
  value       = module.ram.ci_user_name
}

output "ram_env_admin_role_name" {
  description = "Environment admin RAM role name (for assume-role)"
  value       = module.ram.env_admin_role_name
}

output "ram_env_admin_role_arn" {
  description = "Environment admin RAM role ARN"
  value       = module.ram.env_admin_role_arn
}
