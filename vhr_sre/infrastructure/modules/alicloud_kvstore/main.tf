resource "alicloud_kvstore_instance" "redis" {
  engine_version   = var.redis_version
  instance_type    = var.redis_instance_type
  instance_class   = var.redis_instance_class
  zone_id          = var.dr_availability_zone != "" ? "${var.availability_zone},${var.dr_availability_zone}" : var.availability_zone
  vswitch_id       = var.dr_vswitch_id != "" ? "${var.db_vswitch_id},${var.dr_vswitch_id}" : var.db_vswitch_id
  security_ips     = var.security_ip_list
  db_instance_name = "${var.environment}-vhr-redis"
  payment_type     = "PostPaid"
  enable_backup_log = var.enable_backup_log

  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "redis"
  }
}
