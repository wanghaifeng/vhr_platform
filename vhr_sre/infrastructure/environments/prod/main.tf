provider "alicloud" {
  region = var.region
}

module "vpc" {
  source      = "../../modules/alicloud_vpc"
  environment = var.environment
  vpc_name    = "${var.project_name}-${var.environment}"
  cidr_block  = "10.16.0.0/16"
  
  frontend_cidr = "10.16.1.0/24"
  backend_cidr  = "10.16.2.0/24"
  db_cidr       = "10.16.3.0/24"

  allowed_db_ports = ["3306", "6379"]
}

module "ecs" {
  source      = "../../modules/alicloud_ecs"
  environment = var.environment
  image_id    = var.ecs_image_id
  instance_type = {
    frontend = "ecs.c6.2xlarge"
    backend  = "ecs.c6.2xlarge"
  }
  instance_counts = {
    frontend = 2
    backend  = 4
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
  mysql_instance_type = "rds.mysql.s4.large"
  mysql_instance_storage = 200
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
  redis_instance_storage = 200
  redis_password    = var.redis_password
}

module "oss" {
  source            = "../../modules/alicloud_oss"
  environment       = var.environment
  oss_allowed_origins = var.oss_allowed_origins
}

# Best Practice: Use NLB for Cloud Native ACK Ingress in Prod
module "nlb" {
  source              = "../../modules/alicloud_nlb"
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  vswitch_id          = module.vpc.frontend_vswitch_id
  availability_zone   = module.vpc.availability_zone
  backend_server_ids  = module.ecs.frontend_instance_ids # In production, these nodes run Ingress Controller
  backend_port        = 80
  address_type        = "Internet"
  enable_https        = true
}

# Kubernetes Cluster (Frontend) - Prod Environment
module "ack" {
  source = "../../modules/alicloud_ack"
  
  cluster_name      = "${var.project_name}-${var.environment}"
  vswitch_ids       = [module.vpc.frontend_vswitch_id]
  dr_vswitch_ids    = [module.vpc.frontend_vswitch_id] # Fixed: Cannot be empty when enable_dr is true
  security_group_id = module.vpc.web_security_group_id
  
  k8s_version    = "1.24"
  node_count     = 3
  min_node_count = 3
  max_node_count = 10
  
  node_instance_types = ["ecs.c6.2xlarge"]
  enable_autoscaling  = true
  enable_dr           = true # Production enables DR by default in this architecture
  
  tags = {
    environment = var.environment
    project     = var.project_name
  }
}
