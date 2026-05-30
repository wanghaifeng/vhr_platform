# alicloud_rds

管理阿里云 RDS MySQL 实例，支持高可用/AlwaysOn 部署、自动备份策略、日志备份和白名单配置。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | 部署环境 | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| db_vswitch_id | 数据库 VSwitch ID | string | - | yes |
| availability_zone | 主可用区 | string | - | yes |
| dr_availability_zone | 灾备可用区（高可用部署） | string | "" | no |
| dr_vswitch_id | 灾备 VSwitch ID（高可用部署） | string | "" | no |
| category | RDS 实例系列：Basic、HighAvailability、AlwaysOn | string | "Basic" | no |
| security_ip_list | 允许连接的 IP 地址列表 | list(string) | ["10.0.0.0/8"] | no |
| mysql_version | MySQL 引擎版本 | string | "5.7" | no |
| mysql_instance_type | RDS 实例规格 | string | "rds.mysql.s2.large" | no |
| mysql_instance_storage | RDS 实例存储大小（GB） | number | 20 | no |
| mysql_root_username | MySQL Root 用户名 | string | "root" | no |
| mysql_root_password | MySQL Root 密码 | string (sensitive) | - | yes |
| backup_period | 备份周期（星期几） | set(string) | ["Monday"..."Sunday"] | no |
| backup_time | 备份开始时间窗口（UTC） | string | "02:00Z-03:00Z" | no |
| backup_retention_period | 备份保留天数 | number | 7 | no |
| enable_backup_log | 是否启用日志备份 | bool | false | no |
| log_backup_retention_period | 日志备份保留天数 | number | 7 | no |

## Outputs

| Name | Description |
|------|-------------|
| rds_instance_id | RDS 实例 ID |
| rds_connection_string | RDS 连接字符串 |
| rds_port | RDS 端口 |

## Example Usage

```hcl
module "rds" {
  source = "./modules/alicloud_rds"

  environment       = "prod"
  vpc_id            = "vpc-xxx"
  db_vswitch_id     = "vsw-db-xxx"
  availability_zone = "cn-beijing-a"

  category             = "HighAvailability"
  mysql_version        = "5.7"
  mysql_instance_type  = "rds.mysql.s2.large"
  mysql_instance_storage = 20
  mysql_root_password  = "YourStrongPassword123!"

  backup_retention_period = 7
  enable_backup_log       = true
}
```