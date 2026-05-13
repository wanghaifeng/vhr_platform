output "rds_instance_id" {
  description = "The ID of the RDS instance"
  value       = alicloud_db_instance.mysql.id
}

output "rds_connection_string" {
  description = "The connection string of the RDS instance"
  value       = alicloud_db_instance.mysql.connection_string
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = alicloud_db_instance.mysql.port
}
