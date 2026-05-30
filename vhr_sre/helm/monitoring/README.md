# vhr-monitoring

VHR monitoring stack based on kube-prometheus-stack, deploying Prometheus + Grafana with custom alerting rules.

## Dependencies

| Name | Version | Repository |
|------|---------|------------|
| kube-prometheus-stack | 45.0.0 | https://prometheus-community.github.io/helm-charts |

## Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `kube-prometheus-stack.prometheus.prometheusSpec.retention` | string | `15d` | Prometheus data retention period |
| `kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName` | string | `alicloud-disk-ssd` | Storage class |
| `kube-prometheus-stack.prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage` | string | `50Gi` | Storage size |
| `kube-prometheus-stack.grafana.adminPassword` | string | `admin` | Grafana admin password |
| `customAlerts.enabled` | bool | `true` | Enable custom alerting rules |

### Custom Alert Rules

- FrontendHighErrorRate - Frontend high error rate
- FrontendHighLatency - Frontend high latency
- PodCrashLooping - Pod crash looping
- PodNotReady - Pod not ready
- HighMemoryUsage - High memory usage
- HighCPUUsage - High CPU usage

## Installation

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
