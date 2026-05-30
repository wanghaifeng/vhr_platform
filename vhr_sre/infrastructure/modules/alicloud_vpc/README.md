# alicloud_vpc

Manages Alibaba Cloud VPC and subnets, creating frontend, backend, database, and DR VSwitches with corresponding security group rules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_name | The name of the VPC | string | - | yes |
| cidr_block | The CIDR block for the VPC | string | "10.0.0.0/16" | no |
| frontend_cidr | CIDR for frontend subnet | string | - | yes |
| backend_cidr | CIDR for backend subnet | string | - | yes |
| db_cidr | CIDR for database subnet | string | - | yes |
| dr_cidr | CIDR for disaster recovery subnet | string | "" | no |
| allowed_db_ports | List of ports allowed for database security group | list(string) | ["3306","6379","5672"] | no |
| allowed_external_cidrs | List of external CIDR blocks allowed | list(string) | [] | no |
| environment | Deployment environment | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| frontend_vswitch_id | The ID of the frontend VSwitch |
| backend_vswitch_id | The ID of the backend VSwitch |
| db_vswitch_id | The ID of the database VSwitch |
| dr_vswitch_id | The ID of the DR VSwitch |
| web_security_group_id | The ID of the web security group |
| backend_security_group_id | The ID of the backend security group |
| db_security_group_id | The ID of the database security group |
| availability_zone | The primary availability zone |
| dr_availability_zone | The DR availability zone |
| backend_cidr | The CIDR block of the backend VSwitch |

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
