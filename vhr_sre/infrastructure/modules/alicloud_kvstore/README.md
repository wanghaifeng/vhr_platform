# alicloud_kvstore

Manages Alibaba Cloud KVStore (Redis) instances, supporting cross-AZ high availability deployment, backup policies, and IP whitelist configuration.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Deployment environment | string | - | yes |
| vpc_id | The ID of the VPC | string | - | yes |
| db_vswitch_id | The ID of the database VSwitch | string | - | yes |
| availability_zone | The primary availability zone | string | - | yes |
| dr_availability_zone | The DR availability zone for cross-AZ HA | string | "" | no |
| dr_vswitch_id | The ID of the DR VSwitch for cross-AZ HA | string | "" | no |
| security_ip_list | List of IP addresses allowed to connect | list(string) | ["10.0.0.0/8"] | no |
| redis_version | Redis engine version | string | "5.0" | no |
| redis_instance_type | Redis instance type (Redis or Memcache) | string | "Redis" | no |
| redis_instance_class | Redis instance class | string | "redis.master.small.default" | no |
| redis_instance_storage | Redis instance storage in GB | number | 20 | no |
| redis_password | Password for Redis instance | string (sensitive) | "" | no |
| enable_backup_log | Whether to enable log backup (1=enabled, 0=disabled) | number | 0 | no |

## Outputs

| Name | Description |
|------|-------------|
| redis_instance_id | The ID of the Redis instance |
| redis_connection_string | The connection string of the Redis instance |
| redis_port | The port of the Redis instance |

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
