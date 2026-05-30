# alicloud_nlb

Manages Alibaba Cloud Network Load Balancer (NLB), supporting multi-AZ deployment, TCP/TCPSSL listeners, and backend server group configuration.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name | string | - | yes |
| vpc_id | VPC ID | string | - | yes |
| vswitch_id | VSwitch ID(s) for zone mappings (list for multi-AZ) | list(string) | - | yes |
| availability_zone | Availability zone(s) for NLB mapping (list for multi-AZ) | list(string) | - | yes |
| address_type | Address type: Internet or Intranet | string | "Internet" | no |
| backend_server_ids | List of backend server IDs | list(string) | - | yes |
| backend_server_count | Number of backend servers | number | 0 | no |
| backend_port | Port used by Nginx Ingress Controller | number | 80 | no |
| enable_https | Enable TCP 443 listener | bool | false | no |
| ssl_certificate_id | SSL certificate ID for TCPSSL listener | string | "" | no |
| enable_ssl_at_nlb | Enable SSL termination at NLB | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| nlb_id | NLB instance ID |
| nlb_dns_name | NLB DNS name |
| server_group_id | NLB Server Group ID |

## Example Usage

```hcl
module "nlb" {
  source = "./modules/alicloud_nlb"

  environment       = "prod"
  vpc_id            = "vpc-xxx"
  vswitch_id        = ["vsw-xxx"]
  availability_zone = ["cn-beijing-a"]
  backend_server_ids = ["i-xxx"]

  address_type  = "Internet"
  backend_port  = 80
  enable_https  = true
  ssl_certificate_id = "cert-xxx"
}
```
