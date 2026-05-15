output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "frontend_instance_ids" {
  description = "List of frontend ECS instance IDs"
  value       = module.ecs.frontend_instance_ids
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

output "slb_ip_address" {
  description = "The IP address of the SLB"
  value       = module.slb.slb_ip_address
}

output "slb_id" {
  description = "The ID of the SLB instance"
  value       = module.slb.slb_id
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

# Container Registry outputs
output "acr_registry_endpoint" {
  description = "Container registry endpoint"
  value       = module.acr.registry_endpoint
}

output "acr_frontend_repo_url" {
  description = "Frontend container image URL"
  value       = module.acr.frontend_repo_url
}
