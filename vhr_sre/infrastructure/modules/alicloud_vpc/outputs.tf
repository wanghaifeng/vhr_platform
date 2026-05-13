output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.this.id
}

output "frontend_vswitch_id" {
  description = "The ID of the frontend VSwitch"
  value       = alicloud_vswitch.frontend.id
}

output "backend_vswitch_id" {
  description = "The ID of the backend VSwitch"
  value       = alicloud_vswitch.backend.id
}

output "db_vswitch_id" {
  description = "The ID of the database VSwitch"
  value       = alicloud_vswitch.database.id
}

output "db_security_group_id" {
  description = "The ID of the security group for database layer"
  value       = alicloud_security_group.db_sg.id
}

output "availability_zone" {
  description = "The availability zone used for the subnets"
  value       = data.alicloud_zones.default.zones[0].id
}