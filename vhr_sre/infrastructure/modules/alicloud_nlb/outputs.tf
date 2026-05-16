output "nlb_id" {
  description = "NLB instance ID"
  value       = alicloud_nlb_load_balancer.this.id
}

output "nlb_dns_name" {
  description = "NLB DNS name"
  value       = alicloud_nlb_load_balancer.this.dns_name
}

output "server_group_id" {
  description = "NLB Server Group ID"
  value       = alicloud_nlb_server_group.this.id
}
