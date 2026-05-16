data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_vpc" "this" {
  vpc_name   = var.vpc_name
  cidr_block = var.cidr_block
}

resource "alicloud_vswitch" "frontend" {
  vswitch_name = "${var.vpc_name}-frontend-vsw"
  vpc_id       = alicloud_vpc.this.id
  cidr_block   = var.frontend_cidr
  zone_id      = data.alicloud_zones.default.zones[0].id
}

resource "alicloud_vswitch" "backend" {
  vswitch_name = "${var.vpc_name}-backend-vsw"
  vpc_id       = alicloud_vpc.this.id
  cidr_block   = var.backend_cidr
  zone_id      = data.alicloud_zones.default.zones[0].id
}

resource "alicloud_vswitch" "database" {
  vswitch_name = "${var.vpc_name}-db-vsw"
  vpc_id       = alicloud_vpc.this.id
  cidr_block   = var.db_cidr
  zone_id      = data.alicloud_zones.default.zones[0].id
}

resource "alicloud_vswitch" "dr" {
  count        = var.dr_cidr != "" ? 1 : 0
  vswitch_name = "${var.vpc_name}-dr-vsw"
  vpc_id       = alicloud_vpc.this.id
  cidr_block   = var.dr_cidr
  # Use a different zone for DR if available
  zone_id      = length(data.alicloud_zones.default.zones) > 1 ? data.alicloud_zones.default.zones[1].id : data.alicloud_zones.default.zones[0].id
}

resource "alicloud_security_group" "web_sg" {
  security_group_name = "${var.vpc_name}-web-sg"
  vpc_id = alicloud_vpc.this.id
}

resource "alicloud_security_group" "backend_sg" {
  security_group_name = "${var.vpc_name}-backend-sg"
  vpc_id = alicloud_vpc.this.id
}

resource "alicloud_security_group" "db_sg" {
  security_group_name = "${var.vpc_name}-db-sg"
  vpc_id = alicloud_vpc.this.id
}

resource "alicloud_security_group_rule" "allow_backend_to_db" {
  for_each          = toset(var.allowed_db_ports)

  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "${each.value}/${each.value}"
  priority          = 1
  security_group_id = alicloud_security_group.db_sg.id
  cidr_ip           = alicloud_vswitch.backend.cidr_block
}
