resource "alicloud_kvstore_instance" "redis" {
  engine              = "Redis"
  engine_version      = var.redis_version
  db_instance_class   = var.redis_instance_type
  db_instance_storage = var.redis_instance_storage
  vpc_id              = var.vpc_id
  vswitch_id          = var.db_vswitch_id
  security_ip_list    = var.security_ip_list
  instance_name       = "${var.environment}-vhr-redis"
  zone_id             = var.availability_zone
  architecture_type   = "standalone"
  instance_type       = "TairLocalDistribute"
  payment_type        = "PostPaid"

  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "redis"
  }
}
