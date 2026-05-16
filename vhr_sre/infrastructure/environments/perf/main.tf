provider "alicloud" {
  region = var.region
}

module "vpc" {
  source      = "../../modules/alicloud_vpc"
  environment = var.environment
  vpc_name    = "${var.project_name}-${var.environment}"
  cidr_block  = "10.12.0.0/16"
  
  frontend_cidr = "10.12.1.0/24"
  backend_cidr  = "10.12.2.0/24"
  db_cidr       = "10.12.3.0/24"

  allowed_db_ports = ["3306", "6379"]
}

module "ecs" {
  source      = "../../modules/alicloud_ecs"
  environment = var.environment
  image_id    = var.ecs_image_id
  instance_type = {
    frontend = "ecs.c6.xlarge"
    backend  = "ecs.c6.xlarge"
  }
  instance_counts = {
    frontend = 0 # Frontend migrated to ACK
    backend  = 2
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
  security_ip_list  = [module.vpc.backend_cidr, "10.99.0.0/16"]
  mysql_instance_type = "rds.mysql.s3.large"
  mysql_instance_storage = 100
  mysql_root_password = var.mysql_root_password
}

module "kvstore" {
  source            = "../../modules/alicloud_kvstore"
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  db_vswitch_id     = module.vpc.db_vswitch_id
  availability_zone = module.vpc.availability_zone
  security_ip_list  = [module.vpc.backend_cidr, "10.99.0.0/16"]
  redis_instance_type = "Redis"
  redis_instance_storage = 100
  redis_password    = var.redis_password
}

module "oss" {
  source            = "../../modules/alicloud_oss"
  environment       = var.environment
  oss_allowed_origins = var.oss_allowed_origins
}

# Data source to fetch ACK worker nodes
data "alicloud_instances" "ack_nodes" {
  vswitch_id = module.vpc.frontend_vswitch_id
  tags = {
    "role" = "primary"
    "type" = "kubernetes-cluster"
  }
  depends_on = [module.ack]
}

# Use NLB instead of SLB
module "nlb" {
  source               = "../../modules/alicloud_nlb"
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  vswitch_id           = module.vpc.frontend_vswitch_id
  availability_zone    = module.vpc.availability_zone
  backend_server_ids   = data.alicloud_instances.ack_nodes.ids
  backend_server_count = 3 # Match perf node_count
  backend_port         = 80
  address_type         = "Internet"
  enable_https         = false
}

# Kubernetes Cluster - Perf 环境
module "ack" {
  source = "../../modules/alicloud_ack"
  
  cluster_name      = "${var.project_name}-${var.environment}"
  vswitch_ids       = [module.vpc.frontend_vswitch_id]
  dr_vswitch_ids    = []
  security_group_id = module.vpc.web_security_group_id
  
  k8s_version    = "1.24"
  node_count     = 3
  min_node_count = 2
  max_node_count = 10
  
  node_instance_types = ["ecs.c6.xlarge"]
  enable_autoscaling  = true
  enable_dr           = false
  
  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

# Add ACR for Perf environment
module "acr" {
  source        = "../../modules/alicloud_acr"
  namespace_name = var.project_name
  visibility    = "PRIVATE"
  region        = var.region
}
