# alicloud_oss

管理阿里云对象存储服务（OSS）Bucket，配置 CORS 跨域策略，用于静态资源或文件存储。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | 部署环境 | string | - | yes |
| oss_allowed_origins | CORS 允许的来源列表 | list(string) | ["*"] | no |

## Outputs

| Name | Description |
|------|-------------|
| oss_bucket_name | OSS Bucket 名称 |
| oss_bucket_endpoint | OSS Bucket 端点地址 |

## Example Usage

```hcl
module "oss" {
  source = "./modules/alicloud_oss"

  environment        = "prod"
  oss_allowed_origins = ["https://example.com", "https://app.example.com"]
}
```