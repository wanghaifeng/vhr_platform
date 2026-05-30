# alicloud_slb

管理阿里云传统型负载均衡（SLB），支持 HTTP/HTTPS 监听、健康检查、会话保持和后端服务器挂载。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | 环境名称 | string | - | yes |
| vswitch_id | 负载均衡所在 VSwitch ID | string | - | yes |
| slb_spec | SLB 规格类型 | string | "slb.s1.small" | no |
| address_type | 地址类型：internet 或 intranet | string | "internet" | no |
| internet_charge_type | 公网计费方式 | string | "paybytraffic" | no |
| backend_port | 后端服务器端口 | number | 8080 | no |
| backend_server_ids | 后端 ECS 实例 ID 列表 | list(string) | - | yes |
| server_weight | 后端服务器权重 | number | 100 | no |
| health_check_uri | 健康检查 URI 路径 | string | "/health" | no |
| health_check_domain | 健康检查域名 | string | "" | no |
| enable_sticky_session | 启用会话保持 | bool | true | no |
| enable_https | 启用 HTTPS 监听 | bool | false | no |
| server_certificate_id | HTTPS 使用的 SSL 证书 ID | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| slb_id | SLB 实例 ID |
| slb_name | SLB 实例名称 |
| slb_ip_address | SLB IP 地址 |
| http_listener_id | HTTP 监听 ID |
| https_listener_id | HTTPS 监听 ID |

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