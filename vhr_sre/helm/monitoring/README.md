# vhr-monitoring

VHR 监控栈，基于 kube-prometheus-stack 部署 Prometheus + Grafana，并提供自定义告警规则。

## 依赖项

| 名称 | 版本 | 仓库 |
|------|------|------|
| kube-prometheus-stack | 45.0.0 | https://prometheus-community.github.io/helm-charts |

## 配置

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `kube-prometheus-stack.prometheus.prometheusSpec.retention` | string | `15d` | Prometheus 数据保留时间 |
| `kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName` | string | `alicloud-disk-ssd` | 存储类 |
| `kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage` | string | `50Gi` | 存储大小 |
| `kube-prometheus-stack.grafana.adminPassword` | string | `admin` | Grafana 管理员密码 |
| `customAlerts.enabled` | bool | `true` | 启用自定义告警规则 |

### 自定义告警规则

- FrontendHighErrorRate - 前端高错误率
- FrontendHighLatency - 前端高延迟
- PodCrashLooping - Pod 崩溃循环
- PodNotReady - Pod 未就绪
- HighMemoryUsage - 高内存使用率
- HighCPUUsage - 高 CPU 使用率

## 安装

```bash
# dev
helm install vhr-monitoring ./monitoring -n monitoring -f values-dev.yaml

# test
helm install vhr-monitoring ./monitoring -n monitoring -f values-test.yaml

# staging
helm install vhr-monitoring ./monitoring -n monitoring -f values-staging.yaml

# prod
helm install vhr-monitoring ./monitoring -n monitoring -f values-prod.yaml
```