# alicloud_acr

管理阿里云容器镜像服务（ACR）命名空间及前后端应用镜像仓库，提供统一的容器镜像托管地址。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| namespace_name | ACR 命名空间名称 | string | "vhr" | no |
| visibility | 仓库可见性：PUBLIC 或 PRIVATE | string | "PRIVATE" | no |
| region | 阿里云区域 | string | "cn-beijing" | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace_name | ACR 命名空间名称 |
| frontend_repo_name | 前端镜像仓库名称 |
| frontend_repo_url | 前端镜像仓库 URL |
| backend_repo_name | 后端镜像仓库名称 |
| backend_repo_url | 后端镜像仓库 URL |
| registry_endpoint | 镜像仓库端点地址 |
| namespace_id | 命名空间 ID |

## Example Usage

```hcl
module "acr" {
  source = "./modules/alicloud_acr"

  namespace_name = "vhr"
  visibility     = "PRIVATE"
  region         = "cn-beijing"
}
```