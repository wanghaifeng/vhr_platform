provider "alicloud" {
  region = var.region
}

module "vpc" {
  source      = "../../modules/alicloud_vpc"
  environment = var.environment
  vpc_name    = "${var.project_name}-${var.environment}"
  cidr_block  = "10.0.0.0/16"
  
  frontend_cidr = "10.0.1.0/24"
  backend_cidr  = "10.0.2.0/24"
  db_cidr       = "10.0.3.0/24"

  # Pass allowed_db_ports for the security group rule in alicloud_vpc module
  allowed_db_ports = ["3306"]
}

module "ecs" {
  source      = "../../modules/alicloud_ecs"
  environment = var.environment
  image_id    = var.ecs_image_id
  instance_type = {
    frontend = "ecs.c6.large"
    backend  = "ecs.c6.large"
  }
  instance_counts = {
    frontend = 1
    backend  = 1
  }
  frontend_vswitch_id     = module.vpc.frontend_vswitch_id
  backend_vswitch_id      = module.vpc.backend_vswitch_id
  frontend_security_group_id = module.vpc.web_security_group_id
  backend_security_group_id  = module.vpc.backend_security_group_id
}

module "rds" {
  source            = "../../modules/alicloud_rds"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  db_vswitch_id     = module.vpc.db_vswitch_id
  availability_zone = module.vpc.availability_zone
  security_ip_list  = [module.vpc.backend_cidr]
  mysql_root_password = var.mysql_root_password
  mysql_version     = "8.0"
  mysql_instance_type = "rds.mysql.c6.large"
  mysql_instance_storage = 20
  mysql_root_username = "root"
}

module "kvstore" {
  source            = "../../modules/alicloud_kvstore"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  db_vswitch_id     = module.vpc.db_vswitch_id
  availability_zone = module.vpc.availability_zone
  security_ip_list  = [module.vpc.backend_cidr]
  redis_password    = var.redis_password
  redis_version     = "5.0"
  redis_instance_type = "Redis"
  redis_instance_storage = 10
}

module "oss" {
  source            = "../../modules/alicloud_oss"
  environment       = var.environment
  oss_allowed_origins = var.oss_allowed_origins
}

module "slb" {
  source              = "../../modules/alicloud_slb"
  environment         = var.environment
  vswitch_id          = module.vpc.frontend_vswitch_id
  backend_server_ids  = module.ecs.frontend_instance_ids
  backend_port        = 8080
  slb_spec            = "slb.s1.small"
  address_type        = "internet"
  health_check_uri    = "/actuator/health"
  enable_sticky_session = true
  enable_https        = false
}
