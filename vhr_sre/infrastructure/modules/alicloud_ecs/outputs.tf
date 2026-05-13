output "frontend_instance_ids" {
  description = "List of frontend ECS instance IDs"
  value       = alicloud_instance.frontend.*.id
}

output "backend_instance_ids" {
  description = "List of backend ECS instance IDs"
  value       = alicloud_instance.backend.*.id
}
