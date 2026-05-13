resource "alicloud_kvstore_instance" "redis" {
  engine_version      = var.redis_version
  instance_type       = var.redis_instance_type
  zone_id             = var.availability_zone
  vswitch_id          = var.db_vswitch_id
  security_ips        = var.security_ip_list
  db_instance_name    = "${var.environment}-vhr-redis"
  payment_type        = "PostPaid"

  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "redis"
  }
}
