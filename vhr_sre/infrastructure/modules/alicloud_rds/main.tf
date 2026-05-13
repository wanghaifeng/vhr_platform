resource "alicloud_db_instance" "mysql" {
  engine           = "MySQL"
  engine_version   = var.mysql_version
  instance_type    = var.mysql_instance_type
  instance_storage = var.mysql_instance_storage
  instance_charge_type = "Postpaid"
  db_instance_storage_type = "cloud_ssd"
  vpc_id           = var.vpc_id
  vswitch_id       = var.db_vswitch_id
  security_ip_list = var.security_ip_list
  instance_name    = "${var.environment}-vhr-mysql"
  zone_id          = var.availability_zone
  parameters = [
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "max_connections"
      value = "200"
    }
  ]
  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "mysql"
  }
}

resource "alicloud_db_account" "mysql_root" {
  db_instance_id = alicloud_db_instance.mysql.id
  account_name   = var.mysql_root_username
  account_password = var.mysql_root_password
  description    = "Root account for vhr-mysql"
}

resource "alicloud_db_database" "vhr_db" {
  db_instance_id = alicloud_db_instance.mysql.id
  db_name        = "vhr"
  character_set_name = "utf8mb4"
}
