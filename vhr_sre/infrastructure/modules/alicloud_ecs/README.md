# alicloud_ecs

Manages Alibaba Cloud ECS instances, creating separate frontend and backend server groups with customizable instance types, counts, and network configuration.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Deployment environment | string | - | yes |
| image_id | The ID of the ECS image to use | string | - | yes |
| instance_type | Map of instance types for frontend and backend | map(string) | {"frontend":"ecs.c6.large","backend":"ecs.c6.large"} | no |
| instance_counts | Map of instance counts for frontend and backend | map(number) | {"frontend":1,"backend":1} | no |
| frontend_vswitch_id | The ID of the frontend VSwitch | string | - | yes |
| backend_vswitch_id | The ID of the backend VSwitch | string | - | yes |
| frontend_security_group_id | The ID of the security group for the frontend instances | string | - | yes |
| backend_security_group_id | The ID of the security group for the backend instances | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| frontend_instance_ids | List of frontend ECS instance IDs |
| backend_instance_ids | List of backend ECS instance IDs |

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
