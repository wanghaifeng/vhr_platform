# VHR Frontend Helm Chart

Helm Chart for deploying VHR Frontend to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- NGINX Ingress Controller (optional)

## Installation

### Install from local chart
```bash
# Dev environment
helm install vhr-frontend ./vhr_sre/helm/vhr-frontend -f ./vhr_sre/helm/vhr-frontend/values-dev.yaml -n vhr-dev

# Test environment
helm install vhr-frontend ./vhr_sre/helm/vhr-frontend -f ./vhr_sre/helm/vhr-frontend/values-test.yaml -n vhr-test

# Staging environment
helm install vhr-frontend ./vhr_sre/helm/vhr-frontend -f ./vhr_sre/helm/vhr-frontend/values-staging.yaml -n vhr-staging

# Production environment
helm install vhr-frontend ./vhr_sre/helm/vhr-frontend -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml -n vhr-prod
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `image.repository` | Image repository | `registry.cn-beijing.aliyuncs.com/vhr/frontend` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class | `nginx` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Min replicas for HPA | `1` |
| `autoscaling.maxReplicas` | Max replicas for HPA | `10` |

## Upgrade

```bash
helm upgrade vhr-frontend ./vhr_sre/helm/vhr-frontend -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml -n vhr-prod
```

## Rollback

```bash
helm rollback vhr-frontend 1 -n vhr-prod
```

## Uninstall

```bash
helm uninstall vhr-frontend -n vhr-prod
```

## Verify

```bash
helm ls -n vhr-prod
helm status vhr-frontend -n vhr-prod
kubectl get all -n vhr-prod -l app.kubernetes.io/name=vhr-frontend
```
