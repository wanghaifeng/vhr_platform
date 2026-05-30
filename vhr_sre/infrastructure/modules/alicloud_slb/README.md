# alicloud_slb

Manages Alibaba Cloud Server Load Balancer (SLB), supporting HTTP/HTTPS listeners, health checks, sticky sessions, and backend server attachment.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name | string | - | yes |
| vswitch_id | VSwitch ID for the load balancer | string | - | yes |
| slb_spec | SLB specification type | string | "slb.s1.small" | no |
| address_type | Address type: internet or intranet | string | "internet" | no |
| internet_charge_type | Internet charge type | string | "paybytraffic" | no |
| backend_port | Backend server port | number | 8080 | no |
| backend_server_ids | List of backend ECS instance IDs | list(string) | - | yes |
| server_weight | Weight for backend servers | number | 100 | no |
| health_check_uri | Health check URI path | string | "/health" | no |
| health_check_domain | Health check domain | string | "" | no |
| enable_sticky_session | Enable sticky session | bool | true | no |
| enable_https | Enable HTTPS listener | bool | false | no |
| server_certificate_id | SSL certificate ID for HTTPS | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| slb_id | SLB instance ID |
| slb_name | SLB instance name |
| slb_ip_address | SLB IP address |
| http_listener_id | HTTP listener ID |
| https_listener_id | HTTPS listener ID |

## Example Usage

```hcl
module "slb" {
  source = "./modules/alicloud_slb"

  environment        = "prod"
  vswitch_id         = "vsw-xxx"
  backend_server_ids = ["i-xxx", "i-yyy"]

  address_type    = "internet"
  backend_port    = 8080
  health_check_uri = "/health"
  enable_https    = true
  server_certificate_id = "cert-xxx"
}
```
