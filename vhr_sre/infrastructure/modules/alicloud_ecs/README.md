# alicloud_ecs

管理阿里云 ECS 实例，分别创建前端和后端服务器组，支持自定义实例规格、数量及网络配置。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | 部署环境 | string | - | yes |
| image_id | 使用的 ECS 镜像 ID | string | - | yes |
| instance_type | 前端和后端实例规格映射 | map(string) | {"frontend":"ecs.c6.large","backend":"ecs.c6.large"} | no |
| instance_counts | 前端和后端实例数量映射 | map(number) | {"frontend":1,"backend":1} | no |
| frontend_vswitch_id | 前端 VSwitch ID | string | - | yes |
| backend_vswitch_id | 后端 VSwitch ID | string | - | yes |
| frontend_security_group_id | 前端实例安全组 ID | string | - | yes |
| backend_security_group_id | 后端实例安全组 ID | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| frontend_instance_ids | 前端实例 ID 列表 |
| backend_instance_ids | 后端实例 ID 列表 |

## Example Usage

```hcl
module "ecs" {
  source = "./modules/alicloud_ecs"

  environment               = "prod"
  image_id                  = "ami-xxx"
  frontend_vswitch_id       = "vsw-frontend-xxx"
  backend_vswitch_id        = "vsw-backend-xxx"
  frontend_security_group_id = "sg-frontend-xxx"
  backend_security_group_id  = "sg-backend-xxx"

  instance_counts = {
    frontend = 2
    backend  = 3
  }
}
```