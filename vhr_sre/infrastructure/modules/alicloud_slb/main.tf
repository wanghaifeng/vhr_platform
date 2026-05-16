resource "alicloud_slb_load_balancer" "main" {
  load_balancer_name = "${var.environment}-vhr-slb"
  vswitch_id         = var.vswitch_id
  load_balancer_spec = var.slb_spec
  address_type       = var.address_type
  internet_charge_type = var.internet_charge_type

  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "load-balancer"
  }
}

# HTTP Listener (Port 80)
resource "alicloud_slb_listener" "http" {
  load_balancer_id = alicloud_slb_load_balancer.main.id
  frontend_port    = 80
  backend_port     = var.backend_port
  protocol         = "http"
  bandwidth        = -1

  health_check              = "on"
  health_check_type         = "http"
  health_check_connect_port = var.backend_port
  health_check_uri          = var.health_check_uri
  health_check_domain       = var.health_check_domain
  healthy_threshold         = 3
  unhealthy_threshold       = 3
  health_check_timeout      = 5
  health_check_interval     = 5

  sticky_session            = var.enable_sticky_session ? "on" : "off"
  sticky_session_type       = var.enable_sticky_session ? "insert" : ""
  cookie_timeout            = var.enable_sticky_session ? 86400 : 0
}

# HTTPS Listener (Port 443)
resource "alicloud_slb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_id  = alicloud_slb_load_balancer.main.id
  frontend_port     = 443
  backend_port      = var.backend_port
  protocol          = "https"
  bandwidth         = -1
  server_certificate_id = var.ssl_certificate_id # Fixed: ssl_certificate_id is deprecated

  health_check              = "on"
  health_check_type         = "http"
  health_check_connect_port = var.backend_port
  health_check_uri          = var.health_check_uri
  health_check_domain       = var.health_check_domain
  healthy_threshold         = 3
  unhealthy_threshold       = 3
  health_check_timeout      = 5
  health_check_interval     = 5

  sticky_session            = var.enable_sticky_session ? "on" : "off"
  sticky_session_type       = var.enable_sticky_session ? "insert" : ""
  cookie_timeout            = var.enable_sticky_session ? 86400 : 0
}

# Backend Servers Attachment
resource "alicloud_slb_backend_server" "frontend_servers" {
  load_balancer_id = alicloud_slb_load_balancer.main.id

  dynamic "backend_servers" {
    for_each = var.backend_server_ids
    content {
      server_id = backend_servers.value
      weight    = var.server_weight
    }
  }
}
