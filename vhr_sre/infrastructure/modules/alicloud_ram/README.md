# alicloud_ram

管理阿里云 RAM（访问控制）用户、角色和策略，支持创建 CI/CD 用户（含 AKSK）、只读用户、环境管理员角色及 ACK 工作节点策略。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | 部署环境 | string | - | yes |
| project_name | 项目名称，用作 RAM 命名前缀 | string | "vhr" | no |
| region | 阿里云区域，用于资源范围限定 | string | "cn-beijing" | no |
| vpc_id | VPC ID，用于环境范围策略条件 | string | - | yes |
| create_ci_user | 创建 CI/CD RAM 用户及 AKSK | bool | true | no |
| ci_user_name | CI/CD RAM 用户名称 | string | "" | no |
| create_readonly_user | 创建只读 RAM 用户 | bool | false | no |
| readonly_user_name | 只读 RAM 用户名称 | string | "" | no |
| environment_admin_ram_role_name | 环境管理员 RAM 角色名称 | string | "" | no |
| create_ack_worker_policy | 创建 ACK 工作节点范围策略 | bool | false | no |
| ack_worker_ram_role_name | ACK 集群工作节点 RAM 角色名称 | string | "" | no |
| allowed_actions | CI/CD 用户允许的操作模式列表 | list(string) | [] | no |
| deny_actions | 显式拒绝的操作模式列表 | list(string) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| ci_user_name | CI/CD 用户名称 |
| ci_access_key_id | CI/CD 用户 AccessKey ID（敏感） |
| ci_access_key_secret | CI/CD 用户 AccessKey Secret（敏感） |
| ci_policy_name | CI/CD 策略名称 |
| readonly_user_name | 只读用户名称 |
| readonly_policy_name | 只读策略名称 |
| env_admin_role_name | 环境管理员角色名称 |
| env_admin_role_arn | 环境管理员角色 ARN |
| env_admin_policy_name | 环境管理员策略名称 |
| ack_worker_policy_name | ACK 工作节点策略名称 |

## Example Usage

```hcl
module "ram" {
  source = "./modules/alicloud_ram"

  environment = "prod"
  vpc_id      = "vpc-xxx"

  create_ci_user    = true
  create_readonly_user = true
  create_ack_worker_policy = true
  ack_worker_ram_role_name = "KubernetesWorkerRole-prod"
}
```