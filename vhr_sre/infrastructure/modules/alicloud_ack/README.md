# alicloud_ack

Manages Alibaba Cloud ACK (Container Service for Kubernetes) clusters, supporting primary and DR cluster creation, Istio service mesh, and Argo Rollouts progressive delivery addons.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Name of the Kubernetes cluster | string | - | yes |
| vswitch_ids | List of vswitch IDs for primary cluster nodes | list(string) | - | yes |
| dr_vswitch_ids | List of vswitch IDs for secondary cluster nodes (DR) | list(string) | [] | no |
| security_group_id | Security group ID for cluster nodes | string | - | yes |
| k8s_version | Kubernetes version | string | "1.24" | no |
| service_cidr | Service CIDR for primary cluster | string | "172.19.0.0/20" | no |
| pod_cidr | Pod CIDR for primary cluster | string | "10.99.0.0/16" | no |
| dr_service_cidr | Service CIDR for secondary cluster (DR) | string | "172.20.0.0/20" | no |
| dr_pod_cidr | Pod CIDR for secondary cluster (DR) | string | "10.100.0.0/16" | no |
| node_instance_types | Instance types for worker nodes | list(string) | ["ecs.c6.large"] | no |
| node_count | Number of worker nodes | number | 3 | no |
| min_node_count | Minimum number of nodes for autoscaling | number | 2 | no |
| max_node_count | Maximum number of nodes for autoscaling | number | 10 | no |
| enable_autoscaling | Enable cluster autoscaling | bool | true | no |
| enable_dr | Enable disaster recovery (secondary cluster) | bool | false | no |
| enable_istio | Enable Istio service mesh addon on the cluster(s) | bool | false | no |
| istio_version | Istio addon version (leave empty for provider default) | string | "" | no |
| enable_argo_rollouts | Enable Argo Rollouts for progressive delivery | bool | false | no |
| key_name | SSH key pair name | string | "" | no |
| system_disk_size | System disk size in GB | number | 100 | no |
| data_disk_size | Data disk size in GB | number | 200 | no |
| user_data | User data script for node initialization | string | "" | no |
| node_labels | Labels to apply to worker nodes | map(string) | {} | no |
| node_taints | Taints to apply to worker nodes | list(object) | [] | no |
| maintenance_time | Maintenance window start time (HH:MM:SS) | string | "02:00:00" | no |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| primary_cluster_id | Primary cluster ID |
| primary_cluster_name | Primary cluster name |
| primary_cluster_endpoint | Primary cluster API Server endpoint |
| primary_cluster_version | Primary cluster Kubernetes version |
| primary_worker_role_arn | Primary cluster worker RAM role ARN |
| primary_security_group_id | Primary cluster security group ID |
| secondary_cluster_id | Secondary cluster ID (DR) |
| secondary_cluster_name | Secondary cluster name (DR) |
| secondary_cluster_endpoint | Secondary cluster API Server endpoint (DR) |
| secondary_cluster_version | Secondary cluster Kubernetes version (DR) |
| primary_node_pool_id | Primary cluster node pool ID |
| secondary_node_pool_id | Secondary cluster node pool ID (DR) |
| dr_enabled | Disaster recovery enabled status |
| istio_enabled | Istio service mesh enabled status |
| argo_rollouts_enabled | Argo Rollouts enabled status |
| clusters | Summary of all clusters |

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
