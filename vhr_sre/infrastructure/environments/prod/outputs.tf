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

output "nlb_dns_name" {
  description = "The DNS name of the NLB"
  value       = module.nlb.nlb_dns_name
}

output "nlb_id" {
  description = "The ID of the NLB instance"
  value       = module.nlb.nlb_id
}
