# alicloud_vpc

管理阿里云 VPC 网络及子网，创建前端、后端、数据库和灾备 VSwitch，并配置对应的安全组规则。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_name | VPC 名称 | string | - | yes |
| cidr_block | VPC CIDR 网段 | string | "10.0.0.0/16" | no |
| frontend_cidr | 前端子网 CIDR | string | - | yes |
| backend_cidr | 后端子网 CIDR | string | - | yes |
| db_cidr | 数据库子网 CIDR | string | - | yes |
| dr_cidr | 灾备子网 CIDR | string | "" | no |
| allowed_db_ports | 数据库安全组允许的端口列表 | list(string) | ["3306","6379","5672"] | no |
| allowed_external_cidrs | 允许的外部 CIDR 列表 | list(string) | [] | no |
| environment | 部署环境 | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| frontend_vswitch_id | 前端 VSwitch ID |
| backend_vswitch_id | 后端 VSwitch ID |
| db_vswitch_id | 数据库 VSwitch ID |
| dr_vswitch_id | 灾备 VSwitch ID |
| web_security_group_id | Web 安全组 ID |
| backend_security_group_id | 后端安全组 ID |
| db_security_group_id | 数据库安全组 ID |
| availability_zone | 主可用区 |
| dr_availability_zone | 灾备可用区 |
| backend_cidr | 后端子网 CIDR |

## Example Usage

```hcl
module "vpc" {
  source = "./modules/alicloud_vpc"

  vpc_name       = "vhr-prod"
  environment    = "prod"
  cidr_block     = "10.0.0.0/16"
  frontend_cidr  = "10.0.1.0/24"
  backend_cidr   = "10.0.2.0/24"
  db_cidr        = "10.0.3.0/24"
  dr_cidr        = "10.0.4.0/24"

  allowed_db_ports       = ["3306", "6379"]
  allowed_external_cidrs = ["0.0.0.0/0"]
}
```