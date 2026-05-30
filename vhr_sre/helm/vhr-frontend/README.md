# vhr-frontend

VHR 前端应用 Helm Chart，基于 Nginx 托管 Vue.js 应用，支持 Ingress、HPA 自动扩缩容以及 Argo Rollouts 渐进式交付。

## 配置

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `replicaCount` | number | `2` | 副本数 |
| `image.repository` | string | `registry.cn-beijing.aliyuncs.com/vhr/frontend` | 镜像仓库 |
| `image.pullPolicy` | string | `IfNotPresent` | 镜像拉取策略 |
| `image.tag` | string | `latest` | 镜像标签 |
| `service.type` | string | `ClusterIP` | Service 类型 |
| `service.port` | number | `80` | Service 端口 |
| `ingress.enabled` | bool | `true` | 启用 Ingress |
| `ingress.className` | string | `nginx` | Ingress 类 |
| `resources.limits.cpu` | string | `500m` | CPU 限制 |
| `resources.limits.memory` | string | `512Mi` | 内存限制 |
| `resources.requests.cpu` | string | `100m` | CPU 请求 |
| `resources.requests.memory` | string | `128Mi` | 内存请求 |
| `autoscaling.enabled` | bool | `false` | 启用 HPA |
| `autoscaling.minReplicas` | number | `1` | 最小副本数 |
| `autoscaling.maxReplicas` | number | `10` | 最大副本数 |
| `rollout.enabled` | bool | `false` | 启用 Argo Rollouts 渐进式交付 |
| `rollout.strategy` | string | `canary` | 发布策略 (canary/blueGreen) |
| `rollout.canary.steps` | list | 6步渐进 | Canary 步骤 |
| `rollout.canary.analysis.enabled` | bool | `false` | 启用分析回测 |
| `istio.enabled` | bool | `false` | 启用 Istio VirtualService |
| `istio.host` | string | `""` | Istio 主机名 |
| `istio.gateway` | string | `istio-system/default-gateway` | Istio 网关 |

## 安装

```bash
# dev
helm install vhr-frontend ./vhr-frontend -n vhr -f values-dev.yaml

# test
helm install vhr-frontend ./vhr-frontend -n vhr -f values-test.yaml

# staging
helm install vhr-frontend ./vhr-frontend -n vhr -f values-staging.yaml

# prod
helm install vhr-frontend ./vhr-frontend -n vhr -f values-prod.yaml
```

## 渐进式交付

### Canary 发布（默认）

启用 Argo Rollouts 渐进式交付，使用 Canary 策略逐步切换流量：

```yaml
rollout:
  enabled: true
  strategy: canary
  canary:
    steps:
      - setWeight: 10
      - pause: { duration: 1m }
      - setWeight: 30
      - pause: { duration: 1m }
      - setWeight: 60
      - pause: { duration: 1m }
    analysis:
      enabled: true
```

### Blue-Green 发布

切换为 Blue-Green 策略，一次性切换全部流量：

```yaml
rollout:
  enabled: true
  strategy: blueGreen
```

### Istio 流量管理

配合 Istio 实现精确的流量权重控制，需同时启用 Rollout 和 Istio：

```yaml
rollout:
  enabled: true
  strategy: canary
istio:
  enabled: true
  host: vhr.example.com
  gateway: istio-system/default-gateway
```

当 `rollout.enabled=true` 且 `istio.enabled=true` 时，Argo Rollouts 将通过 Istio VirtualService 管理流量权重，实现更精细的 Canary 流量分配。仅启用 `rollout.enabled=true` 而不启用 Istio 时，Rollouts 将使用 Kubernetes 原生方式（按 Pod 比例）控制流量。
