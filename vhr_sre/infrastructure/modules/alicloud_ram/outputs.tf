output "ci_user_name" {
  description = "CI/CD RAM user name"
  value       = var.create_ci_user ? alicloud_ram_user.ci[0].name : ""
}

output "ci_access_key_id" {
  description = "CI/CD RAM user AccessKey ID (store in secrets manager!)"
  value       = var.create_ci_user ? alicloud_ram_access_key.ci[0].id : ""
  sensitive   = true
}

output "ci_access_key_secret" {
  description = "CI/CD RAM user AccessKey Secret (store in secrets manager!)"
  value       = var.create_ci_user ? alicloud_ram_access_key.ci[0].secret : ""
  sensitive   = true
}

output "ci_policy_name" {
  description = "CI/CD RAM policy name"
  value       = var.create_ci_user ? alicloud_ram_policy.ci[0].policy_name : ""
}

output "readonly_user_name" {
  description = "Read-only RAM user name"
  value       = var.create_readonly_user ? alicloud_ram_user.readonly[0].name : ""
}

output "readonly_policy_name" {
  description = "Read-only RAM policy name"
  value       = var.create_readonly_user ? alicloud_ram_policy.readonly[0].policy_name : ""
}

output "env_admin_role_name" {
  description = "Environment admin RAM role name (for assume-role)"
  value       = alicloud_ram_role.env_admin.name
}

output "env_admin_role_arn" {
  description = "Environment admin RAM role ARN"
  value       = alicloud_ram_role.env_admin.arn
}

output "env_admin_policy_name" {
  description = "Environment admin RAM policy name"
  value       = alicloud_ram_policy.env_admin.policy_name
}

output "ack_worker_policy_name" {
  description = "ACK worker scoped policy name (empty if not created)"
  value       = var.create_ack_worker_policy ? alicloud_ram_policy.ack_worker[0].policy_name : ""
}
