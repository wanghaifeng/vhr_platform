# alicloud_rds

Manages Alibaba Cloud RDS MySQL instances, supporting HighAvailability/AlwaysOn deployment, automated backup policies, log backup, and IP whitelist configuration.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Deployment environment | string | - | yes |
| vpc_id | The ID of the VPC | string | - | yes |
| db_vswitch_id | The ID of the database VSwitch | string | - | yes |
| availability_zone | The primary availability zone | string | - | yes |
| dr_availability_zone | The DR availability zone for HA deployment | string | "" | no |
| dr_vswitch_id | The ID of the DR VSwitch for HA deployment | string | "" | no |
| category | RDS instance category: Basic, HighAvailability, AlwaysOn | string | "Basic" | no |
| security_ip_list | List of IP addresses allowed to connect | list(string) | ["10.0.0.0/8"] | no |
| mysql_version | MySQL engine version | string | "5.7" | no |
| mysql_instance_type | RDS instance type | string | "rds.mysql.s2.large" | no |
| mysql_instance_storage | RDS instance storage in GB | number | 20 | no |
| mysql_root_username | Root username for MySQL | string | "root" | no |
| mysql_root_password | Root password for MySQL | string (sensitive) | - | yes |
| backup_period | Backup period days | set(string) | ["Monday"..."Sunday"] | no |
| backup_time | Backup start time window in UTC | string | "02:00Z-03:00Z" | no |
| backup_retention_period | Number of days to retain backups | number | 7 | no |
| enable_backup_log | Whether to enable log backup | bool | false | no |
| log_backup_retention_period | Number of days to retain log backups | number | 7 | no |

## Outputs

| Name | Description |
|------|-------------|
| rds_instance_id | The ID of the RDS instance |
| rds_connection_string | The connection string of the RDS instance |
| rds_port | The port of the RDS instance |

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
