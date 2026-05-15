output "namespace_name" {
  description = "ACR namespace name"
  value       = alicloud_cr_namespace.main.name
}

output "frontend_repo_name" {
  description = "Frontend repository full name"
  value       = alicloud_cr_repo.frontend.name
}

output "frontend_repo_url" {
  description = "Frontend repository URL"
  value       = "registry.${var.region}.aliyuncs.com/${alicloud_cr_namespace.main.name}/frontend"
}

output "backend_repo_name" {
  description = "Backend repository full name"
  value       = alicloud_cr_repo.backend.name
}

output "backend_repo_url" {
  description = "Backend repository URL"
  value       = "registry.${var.region}.aliyuncs.com/${alicloud_cr_namespace.main.name}/backend"
}

output "registry_endpoint" {
  description = "Container registry endpoint"
  value       = "registry.${var.region}.aliyuncs.com"
}

output "namespace_id" {
  description = "ACR namespace ID"
  value       = alicloud_cr_namespace.main.id
}
