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

output "dr_vswitch_id" {
  description = "The ID of the disaster recovery VSwitch"
  value       = length(alicloud_vswitch.dr) > 0 ? alicloud_vswitch.dr[0].id : ""
}

output "web_security_group_id" {
  description = "The ID of the security group for web layer"
  value       = alicloud_security_group.web_sg.id
}

output "backend_security_group_id" {
  description = "The ID of the security group for backend layer"
  value       = alicloud_security_group.backend_sg.id
}

output "db_security_group_id" {
  description = "The ID of the security group for database layer"
  value       = alicloud_security_group.db_sg.id
}

output "availability_zone" {
  description = "The availability zone used for the subnets"
  value       = data.alicloud_zones.default.zones[0].id
}

output "dr_availability_zone" {
  description = "The availability zone used for the DR subnets"
  value       = length(data.alicloud_zones.default.zones) > 1 ? data.alicloud_zones.default.zones[1].id : data.alicloud_zones.default.zones[0].id
}

output "backend_cidr" {
  description = "The CIDR block of the backend VSwitch"
  value       = alicloud_vswitch.backend.cidr_block
}
