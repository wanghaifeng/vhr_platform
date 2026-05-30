# alicloud_kvstore

管理阿里云 KVStore（Redis）实例，支持跨可用区高可用部署、备份策略和白名单配置。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | 部署环境 | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| db_vswitch_id | 数据库 VSwitch ID | string | - | yes |
| availability_zone | 主可用区 | string | - | yes |
| dr_availability_zone | 灾备可用区（跨 AZ 高可用） | string | "" | no |
| dr_vswitch_id | 灾备 VSwitch ID（跨 AZ 高可用） | string | "" | no |
| security_ip_list | 允许连接的 IP 地址列表 | list(string) | ["10.0.0.0/8"] | no |
| redis_version | Redis 引擎版本 | string | "5.0" | no |
| redis_instance_type | Redis 实例类型（Redis 或 Memcache） | string | "Redis" | no |
| redis_instance_class | Redis 实例规格 | string | "redis.master.small.default" | no |
| redis_instance_storage | Redis 实例存储大小（GB） | number | 20 | no |
| redis_password | Redis 实例密码 | string (sensitive) | "" | no |
| enable_backup_log | 是否启用日志备份（1=启用，0=禁用） | number | 0 | no |

## Outputs

| Name | Description |
|------|-------------|
| redis_instance_id | Redis 实例 ID |
| redis_connection_string | Redis 连接字符串 |
| redis_port | Redis 端口 |

## Example Usage

```hcl
module "redis" {
  source = "./modules/alicloud_kvstore"

  environment      = "prod"
  vpc_id           = "vpc-xxx"
  db_vswitch_id    = "vsw-db-xxx"
  availability_zone = "cn-beijing-a"

  redis_version        = "5.0"
  redis_instance_class = "redis.master.small.default"
  security_ip_list     = ["10.0.0.0/8"]
}
```