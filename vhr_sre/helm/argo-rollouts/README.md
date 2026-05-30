# argo-rollouts

Argo Rollouts - 基于 Kubernetes 的渐进式交付控制器，集成 Istio 流量管理，支持 Canary 和 Blue-Green 发布策略。

## 依赖项

| 名称 | 版本 | 仓库 |
|------|------|------|
| argo-rollouts | 2.37.8 | https://argoproj.github.io/argo-helm |

## 配置

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `argo-rollouts.controller.metrics.enabled` | bool | `true` | 启用控制器指标 |
| `argo-rollouts.controller.metrics.serviceMonitor.enabled` | bool | `true` | 启用 ServiceMonitor |
| `argo-rollouts.dashboard.enabled` | bool | `true` | 启用 Dashboard |
| `argo-rollouts.dashboard.service.type` | string | `ClusterIP` | Dashboard Service 类型 |
| `argo-rollouts.dashboard.service.port` | number | `3100` | Dashboard 端口 |
| `argo-rollouts.installCRDs` | bool | `true` | 安装 CRD |
| `istioIntegration.enabled` | bool | `true` | 启用 Istio 集成 |
| `istioIntegration.namespace` | string | `istio-system` | Istio 命名空间 |

## 安装

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