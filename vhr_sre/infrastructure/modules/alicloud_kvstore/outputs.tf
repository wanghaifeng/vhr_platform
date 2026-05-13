output "redis_instance_id" {
  description = "The ID of the Redis instance"
  value       = alicloud_kvstore_instance.redis.id
}

output "redis_connection_string" {
  description = "The connection string of the Redis instance"
  value       = alicloud_kvstore_instance.redis.connection_domain
}

output "redis_port" {
  description = "The port of the Redis instance"
  value       = alicloud_kvstore_instance.redis.port
}
