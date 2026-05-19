resource "alicloud_db_instance" "mysql" {
  engine                   = "MySQL"
  engine_version           = var.mysql_version
  instance_type            = var.mysql_instance_type
  instance_storage         = var.mysql_instance_storage
  instance_charge_type     = "Postpaid"
  db_instance_storage_type = "cloud_ssd"
  category                 = var.category
  vpc_id                   = var.vpc_id
  vswitch_id               = var.dr_vswitch_id != "" ? "${var.db_vswitch_id},${var.dr_vswitch_id}" : var.db_vswitch_id
  security_ips  = var.security_ip_list
  instance_name = "${var.environment}-vhr-mysql"
  zone_id       = var.dr_availability_zone != "" ? "${var.availability_zone},${var.dr_availability_zone}" : var.availability_zone

  parameters {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameters {
    name  = "max_connections"
    value = "200"
  }
  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "mysql"
  }
}

resource "alicloud_db_backup_policy" "mysql" {
  instance_id             = alicloud_db_instance.mysql.id
  preferred_backup_period = var.backup_period
  preferred_backup_time   = var.backup_time
  backup_retention_period = var.backup_retention_period
  enable_backup_log       = var.enable_backup_log
  log_backup_retention_period = var.log_backup_retention_period
}

resource "alicloud_db_account" "mysql_root" {
  db_instance_id      = alicloud_db_instance.mysql.id
  account_name        = var.mysql_root_username
  account_password    = var.mysql_root_password
  account_description = "Root account for vhr-mysql"
}

resource "alicloud_db_database" "vhr_db" {
  instance_id    = alicloud_db_instance.mysql.id
  data_base_name = "vhr"
}
