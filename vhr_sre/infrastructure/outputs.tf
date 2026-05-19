# Shared ACR outputs
output "acr_namespace_name" {
  description = "Shared ACR namespace name"
  value       = module.acr.namespace_name
}

output "acr_frontend_repo_url" {
  description = "Frontend repository URL in shared ACR"
  value       = module.acr.frontend_repo_url
}

output "acr_backend_repo_url" {
  description = "Backend repository URL in shared ACR"
  value       = module.acr.backend_repo_url
}

output "acr_registry_endpoint" {
  description = "Shared ACR endpoint"
  value       = module.acr.registry_endpoint
}
