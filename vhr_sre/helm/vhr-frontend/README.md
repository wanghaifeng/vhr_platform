# vhr-frontend

VHR frontend application Helm chart, hosting a Vue.js app via Nginx with Ingress, HPA autoscaling, and Argo Rollouts progressive delivery support.

## Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `replicaCount` | number | `2` | Number of replicas |
| `image.repository` | string | `registry.cn-beijing.aliyuncs.com/vhr/frontend` | Image repository |
| `image.pullPolicy` | string | `IfNotPresent` | Image pull policy |
| `image.tag` | string | `latest` | Image tag |
| `service.type` | string | `ClusterIP` | Service type |
| `service.port` | number | `80` | Service port |
| `ingress.enabled` | bool | `true` | Enable Ingress |
| `ingress.className` | string | `nginx` | Ingress class |
| `resources.limits.cpu` | string | `500m` | CPU limit |
| `resources.limits.memory` | string | `512Mi` | Memory limit |
| `resources.requests.cpu` | string | `100m` | CPU request |
| `resources.requests.memory` | string | `128Mi` | Memory request |
| `autoscaling.enabled` | bool | `false` | Enable HPA |
| `autoscaling.minReplicas` | number | `1` | Minimum replicas |
| `autoscaling.maxReplicas` | number | `10` | Maximum replicas |
| `rollout.enabled` | bool | `false` | Enable Argo Rollouts progressive delivery |
| `rollout.strategy` | string | `canary` | Deployment strategy (canary/blueGreen) |
| `rollout.canary.steps` | list | 6-step progressive | Canary steps |
| `rollout.canary.analysis.enabled` | bool | `false` | Enable analysis templates |
| `istio.enabled` | bool | `false` | Enable Istio VirtualService |
| `istio.host` | string | `""` | Istio hostname |
| `istio.gateway` | string | `istio-system/default-gateway` | Istio gateway |

## Installation

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

## Progressive Delivery

### Canary Deployment (Default)

Enable Argo Rollouts progressive delivery with Canary strategy for gradual traffic shifting:

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

### Blue-Green Deployment

Switch to Blue-Green strategy for instant traffic cutover:

```yaml
rollout:
  enabled: true
  strategy: blueGreen
```

### Istio Traffic Management

Combine with Istio for precise traffic weight control. Both Rollout and Istio must be enabled:

```yaml
rollout:
  enabled: true
  strategy: canary
istio:
  enabled: true
  host: vhr.example.com
  gateway: istio-system/default-gateway
```

When `rollout.enabled=true` and `istio.enabled=true`, Argo Rollouts manages traffic weights via Istio VirtualService for fine-grained Canary traffic distribution. When only `rollout.enabled=true` without Istio, Rollouts uses Kubernetes native pod-proportional traffic control.
