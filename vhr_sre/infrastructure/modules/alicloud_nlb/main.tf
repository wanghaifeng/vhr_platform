resource "alicloud_nlb_load_balancer" "this" {
  load_balancer_name = "${var.environment}-vhr-nlb"
  load_balancer_type = "Network"
  address_type       = var.address_type
  address_ip_version = "Ipv4"
  vpc_id             = var.vpc_id

  zone_mappings {
    vswitch_id = var.vswitch_id
    zone_id    = var.availability_zone
  }

  tags = {
    Environment = var.environment
    Project     = "vhr"
  }
}

resource "alicloud_nlb_server_group" "this" {
  server_group_name        = "${var.environment}-vhr-nlb-sg"
  server_group_type        = "Instance"
  vpc_id                   = var.vpc_id
  scheduler                = "Rr" # Fixed: Must be one of [Wrr Rr Qch Tch Sch Wlc]
  protocol                 = "TCP"
  connection_drain_enabled = true
  connection_drain_timeout = 60

  health_check {
    health_check_enabled = true
    health_check_type    = "TCP"
    healthy_threshold    = 2
    unhealthy_threshold  = 2
    health_check_connect_timeout = 5
    health_check_interval = 10
  }
}

resource "alicloud_nlb_listener" "tcp_80" {
  listener_protocol = "TCP"
  listener_port     = 80
  load_balancer_id  = alicloud_nlb_load_balancer.this.id
  server_group_id   = alicloud_nlb_server_group.this.id
  idle_timeout      = 900
  proxy_protocol_enabled = true
}

resource "alicloud_nlb_listener" "tcp_443" {
  count             = var.enable_https ? 1 : 0
  listener_protocol = "TCP"
  listener_port     = 443
  load_balancer_id  = alicloud_nlb_load_balancer.this.id
  server_group_id   = alicloud_nlb_server_group.this.id
  idle_timeout      = 900
  proxy_protocol_enabled = true
}

# Attach ACK Nodes to NLB Server Group
resource "alicloud_nlb_server_group_server_attachment" "ack_nodes" {
  # Use fixed count to avoid dynamic length errors during plan
  count           = var.backend_server_count
  server_group_id = alicloud_nlb_server_group.this.id
  server_id       = var.backend_server_ids[count.index]
  server_type     = "Ecs"
  port            = var.backend_port
  weight          = 100
}
