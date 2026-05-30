# alicloud_oss

Manages Alibaba Cloud Object Storage Service (OSS) bucket with CORS policy configuration, used for static assets or file storage.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Deployment environment | string | - | yes |
| oss_allowed_origins | List of allowed origins for CORS | list(string) | ["*"] | no |

## Outputs

| Name | Description |
|------|-------------|
| oss_bucket_name | The name of the OSS bucket |
| oss_bucket_endpoint | The endpoint of the OSS bucket |

## Example Usage

```hcl
module "oss" {
  source = "./modules/alicloud_oss"

  environment        = "prod"
  oss_allowed_origins = ["https://example.com", "https://app.example.com"]
}
```
