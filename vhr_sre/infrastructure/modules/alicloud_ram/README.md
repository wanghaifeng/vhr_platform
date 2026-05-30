# alicloud_ram

Manages Alibaba Cloud RAM (Resource Access Management) users, roles, and policies, supporting CI/CD user (with AKSK), read-only user, environment admin role, and ACK worker node policy creation.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Deployment environment | string | - | yes |
| project_name | Project name used as prefix for RAM naming | string | "vhr" | no |
| region | Alibaba Cloud region for resource scope | string | "cn-beijing" | no |
| vpc_id | VPC ID for environment-scoped policy conditions | string | - | yes |
| create_ci_user | Create a CI/CD RAM user with AKSK | bool | true | no |
| ci_user_name | Name for the CI/CD RAM user | string | "" | no |
| create_readonly_user | Create a read-only RAM user | bool | false | no |
| readonly_user_name | Name for the read-only RAM user | string | "" | no |
| environment_admin_ram_role_name | Name for the environment admin RAM role | string | "" | no |
| create_ack_worker_policy | Create a scoped policy for ACK worker nodes | bool | false | no |
| ack_worker_ram_role_name | ACK cluster worker RAM role name | string | "" | no |
| allowed_actions | List of action patterns allowed for CI/CD user | list(string) | [] | no |
| deny_actions | List of action patterns explicitly denied | list(string) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| ci_user_name | CI/CD RAM user name |
| ci_access_key_id | CI/CD RAM user AccessKey ID (sensitive) |
| ci_access_key_secret | CI/CD RAM user AccessKey Secret (sensitive) |
| ci_policy_name | CI/CD RAM policy name |
| readonly_user_name | Read-only RAM user name |
| readonly_policy_name | Read-only RAM policy name |
| env_admin_role_name | Environment admin RAM role name |
| env_admin_role_arn | Environment admin RAM role ARN |
| env_admin_policy_name | Environment admin RAM policy name |
| ack_worker_policy_name | ACK worker scoped policy name |

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
