resource "alicloud_instance" "frontend" {
  count        = var.instance_counts["frontend"]
  image_id     = var.image_id
  instance_type = var.instance_type["frontend"]
  security_groups = [var.frontend_security_group_id]
  vswitch_id   = var.frontend_vswitch_id
  instance_name = "${var.environment}-frontend-${count.index}"
  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "frontend"
  }
}

resource "alicloud_instance" "backend" {
  count        = var.instance_counts["backend"]
  image_id     = var.image_id
  instance_type = var.instance_type["backend"]
  security_groups = [var.backend_security_group_id]
  vswitch_id   = var.backend_vswitch_id
  instance_name = "${var.environment}-backend-${count.index}"
  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "backend"
  }
}
