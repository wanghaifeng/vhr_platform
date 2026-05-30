# alicloud_acr

Manages Alibaba Cloud Container Registry (ACR) namespace and frontend/backend image repositories, providing a unified container image hosting endpoint.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| namespace_name | ACR namespace name | string | "vhr" | no |
| visibility | Repository visibility: PUBLIC or PRIVATE | string | "PRIVATE" | no |
| region | Alibaba Cloud region | string | "cn-beijing" | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace_name | ACR namespace name |
| frontend_repo_name | Frontend repository full name |
| frontend_repo_url | Frontend repository URL |
| backend_repo_name | Backend repository full name |
| backend_repo_url | Backend repository URL |
| registry_endpoint | Container registry endpoint |
| namespace_id | ACR namespace ID |

## Example Usage

```hcl
module "acr" {
  source = "./modules/alicloud_acr"

  namespace_name = "vhr"
  visibility     = "PRIVATE"
  region         = "cn-beijing"
}
```
