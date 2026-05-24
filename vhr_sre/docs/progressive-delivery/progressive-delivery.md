# Progressive Delivery: Canary & Blue-Green with Argo Rollouts + Istio

## Architecture Overview

```
                    ┌─────────────────────────────────────┐
                    │         Istio Gateway               │
                    │   (mTLS, retries, circuit breaker)  │
                    └──────────────┬──────────────────────┘
                                   │
                    ┌──────────────▼──────────────────────┐
                    │       VirtualService                 │
                    │   weight: stable=80, canary=20       │
                    └───────┬──────────────┬──────────────┘
                            │              │
               ┌────────────▼──┐  ┌───────▼──────────┐
               │  DestinationRule│  │  DestinationRule  │
               │   subset: stable│  │  subset: canary   │
               └────────┬───────┘  └──────┬───────────┘
                        │                  │
              ┌─────────▼────┐   ┌────────▼─────┐
              │  Stable Pods  │   │  Canary Pods  │
              │  (v1.2.2)     │   │  (v1.2.3)     │
              └──────────────┘   └──────────────┘
                        │
              ┌─────────▼─────────────────────┐
              │   Argo Rollouts Controller     │
              │   (drives weight progression)  │
              │   (triggers AnalysisRun)       │
              └─────────┬─────────────────────┘
                        │
              ┌─────────▼─────────────────────┐
              │   AnalysisTemplate             │
              │   - success-rate (Prometheus)  │
              │   - latency-p99 (Prometheus)   │
              │   → auto-rollback on failure   │
              └───────────────────────────────┘
```

## Components

| Component | Namespace | Description | Environments |
|-----------|-----------|-------------|-------------|
| Istio (istiod) | istio-system | Service mesh control plane | staging, prod |
| Argo Rollouts Controller | argo-rollouts | Progressive delivery orchestrator | staging, prod |
| Argo Rollouts Dashboard | argo-rollouts | Web UI for rollout monitoring | staging, prod |

## Terraform Configuration

Istio is installed via ACK addon (`alicloud_cs_kubernetes_addon`), Argo Rollouts via Helm chart.

```hcl
# In modules/alicloud_ack/main.tf
resource "alicloud_cs_kubernetes_addon" "istio_primary" {
  count      = var.enable_istio ? 1 : 0
  cluster_id = alicloud_cs_managed_kubernetes.primary.id
  name       = "istio"
  version    = var.istio_version != "" ? var.istio_version : null
}
```

## Helm Chart Structure

### argo-rollouts Chart
```
helm/argo-rollouts/
├── Chart.yaml              # Depends on argoproj/argo-helm argo-rollouts 2.37.8
├── values.yaml             # Default: Istio integration enabled, ServiceMonitor enabled
├── values-dev.yaml         # dev: Istio disabled, minimal resources
├── values-test.yaml        # test: Istio disabled, minimal resources
├── values-staging.yaml     # staging: Istio enabled, 2 replicas
├── values-prod.yaml        # prod: Istio enabled, 2 replicas, pod anti-affinity
└── templates/
    └── rbac.yaml           # ClusterRole for VirtualService/DestinationRule management
```

### vhr-frontend Chart (Rollout Templates)
```
helm/vhr-frontend/templates/
├── rollout.yaml            # Argo Rollouts resource (canary + blueGreen strategies)
├── service-canary.yaml     # canary Service: -canary + -stable
├── service-bluegreen.yaml  # blueGreen Service: -stable + -preview
├── virtualservice.yaml     # Istio VirtualService + DestinationRule
├── analysistemplate.yaml   # Prometheus metric analysis (success-rate, latency-p99)
├── deployment.yaml         # Standard Deployment (used when rollout.enabled=false)
└── service.yaml            # Standard Service (used when rollout.enabled=false)
```

## Canary Release

### How It Works

1. Developer pushes new image tag
2. Argo Rollouts creates a new ReplicaSet (canary)
3. Istio VirtualService weights are progressively shifted:
   - 1% → 5% → 20% → 40% → 60% → 80% → 100%
4. At each step, AnalysisRun queries Prometheus:
   - **success-rate**: `5xx rate < threshold` (must pass 4/6 checks)
   - **latency-p99**: `P99 < 500ms` (must pass 4/6 checks)
5. If analysis fails → **automatic rollback** to stable version
6. If all steps pass → canary becomes the new stable

### Triggering a Canary

```bash
# Method 1: kubectl argo rollouts plugin
kubectl argo rollouts set image vhr-frontend \
  frontend=registry.cn-beijing.aliyuncs.com/vhr/frontend:v1.2.3 -n vhr-prod

# Method 2: Helm upgrade
helm upgrade vhr-frontend ./vhr_sre/helm/vhr-frontend \
  -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml \
  --set image.tag=v1.2.3 \
  --namespace vhr-prod
```

### Monitoring a Canary

```bash
# Watch rollout progress (real-time)
kubectl argo rollouts get rollout vhr-frontend -n vhr-prod --watch

# Check current traffic weights
kubectl get virtualservice vhr-frontend -n vhr-prod \
  -o jsonpath='{.spec.http[0].route[*].weight}'

# Check analysis run status
kubectl get analysisrun -n vhr-prod
kubectl describe analysisrun <analysis-run-name> -n vhr-prod
```

### Canary Step Configuration

| Environment | Steps | Pause Duration | Analysis |
|-------------|-------|----------------|----------|
| staging | 5%→20%→50% | 60s/120s | Enabled |
| prod | 1%→5%→20%→40%→60%→80% | 5min each | Enabled |

### Manual Intervention

```bash
# Promote to next step immediately
kubectl argo rollouts promote vhr-frontend -n vhr-prod

# Promote fully (skip all remaining steps)
kubectl argo rollouts promote vhr-frontend -n vhr-prod --full

# Abort and rollback to stable
kubectl argo rollouts abort vhr-frontend -n vhr-prod

# Pause the rollout (no auto-promotion)
kubectl argo rollouts pause vhr-frontend -n vhr-prod

# Resume a paused rollout
kubectl argo rollouts unpause vhr-frontend -n vhr-prod
```

## Blue-Green Release

### How It Works

1. New "preview" ReplicaSet is created with the new version
2. Preview pods must pass readiness probes
3. Traffic is NOT sent to preview automatically (unlike canary)
4. After `autoPromotionSeconds` (default: 30s), Service switches to preview
5. Old "active" ReplicaSet is scaled down after `scaleDownDelayRevisionLimit`

### Triggering a Blue-Green

```bash
# Switch strategy to blueGreen and deploy
helm upgrade vhr-frontend ./vhr_sre/helm/vhr-frontend \
  -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml \
  --set rollout.strategy=blueGreen \
  --set rollout.blueGreen.autoPromotionSeconds=120 \
  --set image.tag=v1.2.3 \
  --namespace vhr-prod
```

### Manual Switch (Recommended for Prod)

```bash
# 1. Deploy with auto-promotion DISABLED
helm upgrade vhr-frontend ./vhr_sre/helm/vhr-frontend \
  -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml \
  --set rollout.strategy=blueGreen \
  --set rollout.blueGreen.autoPromotionEnabled=false \
  --set image.tag=v1.2.3 \
  --namespace vhr-prod

# 2. Verify preview pods are healthy
kubectl get pods -l role=preview -n vhr-prod

# 3. Run smoke tests against preview
curl http://vhr-frontend-preview.vhr-prod.svc.cluster.local/health

# 4. Manually promote when ready
kubectl argo rollouts promote vhr-frontend -n vhr-prod

# 5. If issues found, rollback instead
kubectl argo rollouts abort vhr-frontend -n vhr-prod
```

## Analysis Templates

### Success Rate Analysis

Checks that the canary version's HTTP success rate remains above threshold:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
    - name: service
  metrics:
    - name: success-rate
      interval: 30s
      count: 6           # Run 6 checks
      successLimit: 4     # At least 4 must pass
      failureLimit: 2     # 2 failures → abort
      provider:
        prometheus:
          query: |
            sum(rate(http_requests_total{status!~"5.*",app="{{args.service}}"}[1m]))
            /
            sum(rate(http_requests_total{app="{{args.service}}"}[1m]))
```

### Latency Analysis

Checks that P99 latency stays below 500ms:

```yaml
    - name: latency-p99
      interval: 30s
      count: 6
      successLimit: 4
      failureLimit: 2
      provider:
        prometheus:
          query: |
            histogram_quantile(0.99,
              sum(rate(http_request_duration_seconds_bucket{app="{{args.service}}"}[1m]))
              by (le)
            )
      successCondition: result < 0.5
```

## Istio Traffic Management

### VirtualService

Managed by Argo Rollouts automatically during canary. Manual overrides:

```bash
# Emergency: shift all traffic to stable
kubectl patch virtualservice vhr-frontend -n vhr-prod -p '{"spec":{"http":[{"route":[{"destination":{"host":"vhr-frontend","subset":"stable"},"weight":100},{"destination":{"host":"vhr-frontend","subset":"canary"},"weight":0}]}]}}'

# Check retry configuration
kubectl get virtualservice vhr-frontend -n vhr-prod -o yaml | grep -A5 retries
```

### DestinationRule

Provides circuit breaking and connection pool settings:

```yaml
trafficPolicy:
  connectionPool:
    http:
      maxRequestsPerConnection: 100
  outlierDetection:
    consecutive5xxErrors: 5
    interval: 30s
    baseEjectionTime: 30s
    maxEjectionPercent: 50
```

## Rollout Dashboard

Access the Argo Rollouts Dashboard for visual monitoring:

```bash
# Port-forward to dashboard
kubectl port-forward svc/argo-rollouts-dashboard -n argo-rollouts 3100:3100

# Open in browser
# http://localhost:3100
```

## Troubleshooting

| Issue | Symptom | Solution |
|-------|---------|----------|
| Rollout stuck | No progression after step | Check AnalysisRun: `kubectl get analysisrun -n vhr-prod` |
| Analysis failing | Canary auto-aborted | Check Prometheus query in AnalysisTemplate |
| Sidecar not injected | No Istio proxy | Label namespace: `kubectl label ns vhr-prod istio-injection=enabled` |
| VirtualService not updated | Traffic not shifting | Check Rollout `trafficRouting.istio` config |
| 5xx errors spike | OutlierDetection ejecting | Review app logs, consider increasing `consecutive5xxErrors` |
