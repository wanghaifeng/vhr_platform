provider "alicloud" {
  region = var.region
}

module "vpc" {
  source      = "../../modules/alicloud_vpc"
  environment = var.environment
  vpc_name    = "${var.project_name}-${var.environment}"
  cidr_block  = "10.4.0.0/16"
  
  frontend_cidr = "10.4.1.0/24"
  backend_cidr  = "10.4.2.0/24"
  db_cidr       = "10.4.3.0/24"

  allowed_db_ports = ["3306", "5672", "6379"]
}

module "ecs" {
  source      = "../../modules/alicloud_ecs"
  environment = var.environment
  image_id    = var.ecs_image_id
  instance_type = {
    frontend = "ecs.c6.medium"
    backend  = "ecs.c6.medium"
  }
  instance_counts = {
    frontend = 1
    backend  = 1
  }
  frontend_vswitch_id     = module.vpc.frontend_vswitch_id
  backend_vswitch_id      = module.vpc.backend_vswitch_id
  frontend_security_group_id = module.vpc.web_security_group_id # Assuming web security group for frontend
  backend_security_group_id  = module.vpc.backend_security_group_id # Assuming backend security group for backend
}

module "rds" {
  source            = "../../modules/alicloud_rds"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  db_vswitch_id     = module.vpc.db_vswitch_id
  availability_zone = module.vpc.availability_zone
  security_ip_list  = [module.vpc.backend_cidr]
  mysql_instance_type = "rds.mysql.s1.small"
  mysql_instance_storage = 10
  mysql_root_password = var.mysql_root_password
}

module "kvstore" {
  source            = "../../modules/alicloud_kvstore"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  db_vswitch_id     = module.vpc.db_vswitch_id
  availability_zone = module.vpc.availability_zone
  security_ip_list  = [module.vpc.backend_cidr]
  redis_instance_type = "Redis"
  redis_instance_storage = 10
  redis_password    = var.redis_password
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
  slb_spec            = "slb.s2.small"
  address_type        = "internet"
  health_check_uri    = "/actuator/health"
  enable_sticky_session = true
  enable_https        = false
}
