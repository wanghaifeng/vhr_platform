# Container Registry Namespace
resource "alicloud_cr_namespace" "main" {
  namespace_name     = var.namespace_name
  auto_create_repo   = true
  default_visibility = var.visibility

  # Namespace name should be globally unique
}

# Frontend Repository
resource "alicloud_cr_repo" "frontend" {
  namespace        = alicloud_cr_namespace.main.namespace_name
  repo_name        = "frontend"
  repo_type        = var.visibility
  summary          = "VHR Frontend Image"
  detail           = "Vue.js frontend application with Nginx"
}

# Backend Repository (for future use)
resource "alicloud_cr_repo" "backend" {
  namespace        = alicloud_cr_namespace.main.namespace_name
  repo_name        = "backend"
  repo_type        = var.visibility
  summary          = "VHR Backend Image"
  detail           = "Spring Boot backend application"
}
