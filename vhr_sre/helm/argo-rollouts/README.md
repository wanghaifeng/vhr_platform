# argo-rollouts

Argo Rollouts - Kubernetes progressive delivery controller with Istio traffic management integration, supporting Canary and Blue-Green deployment strategies.

## Dependencies

| Name | Version | Repository |
|------|---------|------------|
| argo-rollouts | 2.37.8 | https://argoproj.github.io/argo-helm |

## Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `argo-rollouts.controller.metrics.enabled` | bool | `true` | Enable controller metrics |
| `argo-rollouts.controller.metrics.serviceMonitor.enabled` | bool | `true` | Enable ServiceMonitor |
| `argo-rollouts.dashboard.enabled` | bool | `true` | Enable Dashboard |
| `argo-rollouts.dashboard.service.type` | string | `ClusterIP` | Dashboard Service type |
| `argo-rollouts.dashboard.service.port` | number | `3100` | Dashboard port |
| `argo-rollouts.installCRDs` | bool | `true` | Install CRDs |
| `istioIntegration.enabled` | bool | `true` | Enable Istio integration |
| `istioIntegration.namespace` | string | `istio-system` | Istio namespace |

## Installation

```bash
# dev
helm install argo-rollouts ./argo-rollouts -n argo-rollouts -f values-dev.yaml

# test
helm install argo-rollouts ./argo-rollouts -n argo-rollouts -f values-test.yaml

# staging
helm install argo-rollouts ./argo-rollouts -n argo-rollouts -f values-staging.yaml

# prod
helm install argo-rollouts ./argo-rollouts -n argo-rollouts -f values-prod.yaml
```
