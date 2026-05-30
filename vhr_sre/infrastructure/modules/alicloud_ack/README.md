# alicloud_ack

管理阿里云 ACK（Container Service for Kubernetes）集群，支持主集群和灾备集群的创建，以及 Istio 服务网格和 Argo Rollouts 渐进式交付等附加组件的启用。

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Kubernetes 集群名称 | string | - | yes |
| vswitch_ids | 主集群节点使用的 VSwitch ID 列表 | list(string) | - | yes |
| dr_vswitch_ids | 灾备集群节点使用的 VSwitch ID 列表 | list(string) | [] | no |
| security_group_id | 集群节点安全组 ID | string | - | yes |
| k8s_version | Kubernetes 版本 | string | "1.24" | no |
| service_cidr | 主集群 Service CIDR | string | "172.19.0.0/20" | no |
| pod_cidr | 主集群 Pod CIDR | string | "10.99.0.0/16" | no |
| dr_service_cidr | 灾备集群 Service CIDR | string | "172.20.0.0/20" | no |
| dr_pod_cidr | 灾备集群 Pod CIDR | string | "10.100.0.0/16" | no |
| node_instance_types | 工作节点实例规格列表 | list(string) | ["ecs.c6.large"] | no |
| node_count | 工作节点数量 | number | 3 | no |
| min_node_count | 自动扩缩容最小节点数 | number | 2 | no |
| max_node_count | 自动扩缩容最大节点数 | number | 10 | no |
| enable_autoscaling | 启用集群自动扩缩容 | bool | true | no |
| enable_dr | 启用灾备（创建二级集群） | bool | false | no |
| enable_istio | 在集群上启用 Istio 服务网格附加组件 | bool | false | no |
| istio_version | Istio 附加组件版本（留空使用提供商默认值） | string | "" | no |
| enable_argo_rollouts | 启用 Argo Rollouts 渐进式交付 | bool | false | no |
| key_name | SSH 密钥对名称 | string | "" | no |
| system_disk_size | 系统盘大小（GB） | number | 100 | no |
| data_disk_size | 数据盘大小（GB） | number | 200 | no |
| user_data | 节点初始化用户数据脚本 | string | "" | no |
| node_labels | 应用到工作节点的标签 | map(string) | {} | no |
| node_taints | 应用到工作节点的污点 | list(object) | [] | no |
| maintenance_time | 维护窗口开始时间（HH:MM:SS） | string | "02:00:00" | no |
| tags | 应用到资源的标签 | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| primary_cluster_id | 主集群 ID |
| primary_cluster_name | 主集群名称 |
| primary_cluster_endpoint | 主集群 API Server 端点 |
| primary_cluster_version | 主集群 Kubernetes 版本 |
| primary_worker_role_arn | 主集群工作节点 RAM 角色 ARN |
| primary_security_group_id | 主集群安全组 ID |
| secondary_cluster_id | 灾备集群 ID |
| secondary_cluster_name | 灾备集群名称 |
| secondary_cluster_endpoint | 灾备集群 API Server 端点 |
| secondary_cluster_version | 灾备集群 Kubernetes 版本 |
| primary_node_pool_id | 主集群节点池 ID |
| secondary_node_pool_id | 灾备集群节点池 ID |
| dr_enabled | 灾备是否已启用 |
| istio_enabled | Istio 是否已启用 |
| argo_rollouts_enabled | Argo Rollouts 是否已启用 |
| clusters | 所有集群信息汇总 |

## Example Usage

```hcl
module "ack" {
  source = "./modules/alicloud_ack"

  cluster_name      = "vhr-prod"
  vswitch_ids       = ["vsw-xxx"]
  security_group_id = "sg-xxx"

  k8s_version        = "1.24"
  node_instance_types = ["ecs.c6.large"]
  node_count         = 3
  enable_autoscaling = true
  min_node_count     = 2
  max_node_count     = 10

  enable_istio = true
  tags = {
    Environment = "prod"
  }
}
```