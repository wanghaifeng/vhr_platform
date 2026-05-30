# alicloud_nlb

管理阿里云网络型负载均衡（NLB），支持多可用区部署、TCP/TCPSSL 监听及后端服务器组配置。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | 环境名称 | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| vswitch_id | 可用区映射的 VSwitch ID 列表（多 AZ 时为列表） | list(string) | - | yes |
| availability_zone | 可用区映射的可用区列表（多 AZ 时为列表） | list(string) | - | yes |
| address_type | 地址类型：Internet 或 Intranet | string | "Internet" | no |
| backend_server_ids | 后端服务器 ID 列表 | list(string) | - | yes |
| backend_server_count | 后端服务器数量 | number | 0 | no |
| backend_port | Nginx Ingress Controller 使用的端口 | number | 80 | no |
| enable_https | 启用 TCP 443 监听 | bool | false | no |
| ssl_certificate_id | TCPSSL 监听使用的 SSL 证书 ID | string | "" | no |
| enable_ssl_at_nlb | 在 NLB 上启用 SSL 终止 | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| nlb_id | NLB 实例 ID |
| nlb_dns_name | NLB DNS 名称 |
| server_group_id | 后端服务器组 ID |

## Example Usage

```hcl
module "nlb" {
  source = "./modules/alicloud_nlb"

  environment       = "prod"
  vpc_id            = "vpc-xxx"
  vswitch_id        = ["vsw-xxx"]
  availability_zone = ["cn-beijing-a"]
  backend_server_ids = ["i-xxx"]

  address_type  = "Internet"
  backend_port  = 80
  enable_https  = true
  ssl_certificate_id = "cert-xxx"
}
```