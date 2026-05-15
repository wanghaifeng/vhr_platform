output "slb_id" {
  description = "SLB instance ID"
  value       = alicloud_slb_load_balancer.main.id
}

output "slb_name" {
  description = "SLB instance name"
  value       = alicloud_slb_load_balancer.main.load_balancer_name
}

output "slb_ip_address" {
  description = "SLB IP address"
  value       = alicloud_slb_load_balancer.main.address
}

output "http_listener_id" {
  description = "HTTP listener ID"
  value       = alicloud_slb_listener.http.id
}

output "https_listener_id" {
  description = "HTTPS listener ID"
  value       = var.enable_https ? alicloud_slb_listener.https[0].id : ""
}
