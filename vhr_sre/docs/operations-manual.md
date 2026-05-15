# VHR Operations Manual

## Table of Contents
- [Daily Operations](#daily-operations)
- [Troubleshooting](#troubleshooting)
- [Deployment Operations](#deployment-operations)
- [Monitoring & Alerting](#monitoring--alerting)
- [Security Operations](#security-operations)
- [Backup & Recovery](#backup--recovery)

---

## Daily Operations

### 1. Cluster Health Check

#### Kubernetes Cluster Status
```bash
# Check node status
kubectl get nodes -o wide

# Check node resource usage
kubectl top nodes

# Check cluster component status
kubectl get cs

# Check all Pod status
kubectl get pods --all-namespaces

# Check abnormal Pods
kubectl get pods --all-namespaces --field-selector=status.phase!=Running
```

#### Frontend Application Status
```bash
# Check Frontend Deployment
kubectl get deployment vhr-frontend -n vhr-prod

# Check Pod details
kubectl describe deployment vhr-frontend -n vhr-prod

# View logs
kubectl logs -l app.kubernetes.io/name=vhr-frontend -n vhr-prod --tail=100

# Real-time log view
kubectl logs -f -l app.kubernetes.io/name=vhr-frontend -n vhr-prod
```

### 2. Resource Usage Monitoring

```bash
# Pod resource usage
kubectl top pods -n vhr-prod

# Container resource usage
kubectl top pods -n vhr-prod --containers

# View resource limits
kubectl get pods -n vhr-prod -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}'
```

### 3. Log Viewing

#### K8s Application Logs
```bash
# View recent logs
kubectl logs deployment/vhr-frontend -n vhr-prod --tail=200

# View specific time range
kubectl logs deployment/vhr-frontend -n vhr-prod --since=1h

# Multi-container logs
kubectl logs deployment/vhr-frontend -n vhr-prod --all-containers

# Export logs to file
kubectl logs deployment/vhr-frontend -n vhr-prod > frontend.log
```

#### Alibaba Cloud SLS Logs
```
1. Login to Alibaba Cloud console
2. Navigate to Log Service
3. Select vhr-prod project
4. Query examples:
   - Error logs: level: ERROR
   - Slow requests: request_time > 1
   - Specific API: path: "/api/user/*"
```

---

## Troubleshooting

### 1. Pod Issues

#### Pod Stuck in Pending
```bash
# View events
kubectl describe pod <pod-name> -n vhr-prod

# Common causes:
# - Insufficient resources: Check node resources
# - PVC not bound: Check PV/PVC
# - Node selector mismatch: Check nodeSelector/affinity

# Solutions:
kubectl top nodes  # Check node resources
kubectl get pvc -n vhr-prod  # Check PVC status
```

#### Pod in CrashLoopBackOff
```bash
# View logs
kubectl logs <pod-name> -n vhr-prod --previous

# View events
kubectl describe pod <pod-name> -n vhr-prod

# Common causes:
# - Application startup failure: Check app logs
# - Health check failure: Check liveness/readiness probe
# - Insufficient resources: Increase resource limits

# Temporary debugging
kubectl run debug --rm -it --image=busybox -n vhr-prod -- sh
```

#### Pod Restarting Too Frequently
```bash
# View restart count
kubectl get pod <pod-name> -n vhr-prod -o jsonpath='{.status.containerStatuses[0].restartCount}'

# View previous logs
kubectl logs <pod-name> -n vhr-prod --previous
```

### 2. Network Issues

#### Service Unreachable
```bash
# Check Service
kubectl get svc -n vhr-prod
kubectl describe svc vhr-frontend -n vhr-prod

# Check Endpoints
kubectl get endpoints vhr-frontend -n vhr-prod

# Test service connectivity
kubectl run curl-test --rm -it --image=curlimages/curl -n vhr-prod -- \
  curl http://vhr-frontend.vhr-prod.svc.cluster.local
```

#### Ingress Unreachable
```bash
# Check Ingress
kubectl get ingress -n vhr-prod
kubectl describe ingress vhr-frontend -n vhr-prod

# Check Ingress Controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# Check SLB
aliyun slb DescribeLoadBalancerAttribute --LoadBalancerId <slb-id>
```

### 3. Performance Issues

#### Slow Application Response
```bash
# Check Pod resource usage
kubectl top pod <pod-name> -n vhr-prod

# Check HPA status
kubectl get hpa -n vhr-prod

# View application metrics (Prometheus)
# Query: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

#### Memory Leak
```bash
# Monitor memory growth
watch -n 5 'kubectl top pod <pod-name> -n vhr-prod'

# Export heap dump for analysis
kubectl exec <pod-name> -n vhr-prod -- jmap -dump:live,format=b,file=/tmp/heap.hprof 1
kubectl cp vhr-prod/<pod-name>:/tmp/heap.hprof ./heap.hprof
```

---

## Deployment Operations

### 1. Helm Deployment

#### Deploy New Version
```bash
# View current version
helm list -n vhr-prod

# Deploy new version
helm upgrade vhr-frontend ./vhr_sre/helm/vhr-frontend \
  -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml \
  --namespace vhr-prod \
  --set image.tag=v1.2.3 \
  --wait

# View deployment status
helm status vhr-frontend -n vhr-prod

# View version history
helm history vhr-frontend -n vhr-prod
```

#### Rollback Deployment
```bash
# View version history
helm history vhr-frontend -n vhr-prod

# Rollback to specific version
helm rollback vhr-frontend 2 -n vhr-prod

# Verify rollback
helm status vhr-frontend -n vhr-prod
kubectl get pods -l app.kubernetes.io/name=vhr-frontend -n vhr-prod
```

### 2. Scaling

#### Manual Scaling
```bash
# Scale to 5 replicas
kubectl scale deployment vhr-frontend -n vhr-prod --replicas=5

# View status
kubectl get deployment vhr-frontend -n vhr-prod
```

#### Auto Scaling Configuration
```bash
# Check HPA
kubectl get hpa vhr-frontend -n vhr-prod

# Update HPA configuration
kubectl autoscale deployment vhr-frontend -n vhr-prod \
  --min=3 --max=10 --cpu-percent=80
```

---

## Monitoring & Alerting

### 1. Prometheus Queries

#### Common Query Examples
```promql
# Request rate
rate(http_requests_total[5m])

# Error rate
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ sum(rate(http_requests_total[5m]))

# P95 latency
histogram_quantile(0.95, 
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)

# Pod memory usage
container_memory_usage_bytes{namespace="vhr-prod"}

# Pod CPU usage
rate(container_cpu_usage_seconds_total{namespace="vhr-prod"}[5m])
```

### 2. Grafana Dashboards

#### Access Grafana
```bash
# Port forward access
kubectl port-forward svc/grafana -n monitoring 3000:80

# Browser access
http://localhost:3000
# Username: admin
# Password: admin (change after first login)
```

#### Import Dashboards
```
Common Dashboard IDs:
- 315: Kubernetes cluster monitoring
- 6417: Kubernetes pods
- 1860: Node Exporter Full
- 7249: NGINX Ingress controller
```

### 3. Alert Handling

#### View Alerts
```bash
# Access Alertmanager UI
kubectl port-forward svc/alertmanager-operated -n monitoring 9093:9093

# Browser access
http://localhost:9093
```

#### Alert Classification
| Level | Response Time | Notification Method | Example |
|-------|---------------|---------------------|---------|
| Critical | 5 minutes | Phone + DingTalk | Service unavailable, data loss |
| Warning | 30 minutes | DingTalk + Email | High latency, high error rate |
| Info | 4 hours | Email | Capacity warning |

---

## Security Operations

### 1. Access Control

#### RBAC Configuration
```bash
# View roles
kubectl get roles,rolebindings -n vhr-prod

# View cluster roles
kubectl get clusterroles,clusterrolebindings

# Create namespace admin
kubectl create rolebinding dev-admin \
  --clusterrole=admin \
  --user=dev@example.com \
  -n vhr-dev
```

#### ServiceAccount Management
```bash
# View ServiceAccounts
kubectl get serviceaccounts -n vhr-prod

# Create new ServiceAccount
kubectl create serviceaccount vhr-deployer -n vhr-prod
```

### 2. Security Scanning

#### Image Vulnerability Scanning
```bash
# Scan with Trivy
trivy image registry.cn-beijing.aliyuncs.com/vhr/frontend:v1.2.3

# Handle scan results:
# - Critical: Fix immediately
# - High: Fix within 24 hours
# - Medium: Fix within 7 days
```

### 3. Secret Management

#### Secret Management
```bash
# View Secrets
kubectl get secrets -n vhr-prod

# Create Secret
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=xxx \
  -n vhr-prod

# Update Secret
kubectl create secret generic db-credentials \
  --from-literal=password=newpassword \
  -n vhr-prod --dry-run=client -o yaml | kubectl apply -f -
```

---

## Backup & Recovery

### 1. Data Backup

#### Database Backup
```bash
# RDS auto backup (Alibaba Cloud console)
# Daily at 2:00 AM
# Retention: 7 days

# Manual backup
aliyun rds CreateBackup --DBInstanceId <instance-id>

# Backup download
aliyun rds DescribeBackups --DBInstanceId <instance-id>
```

#### Redis Backup
```bash
# Redis cluster auto backup
# Console config: Daily backup, 7 days retention
```

### 2. K8s Resource Backup

#### Backup with Velero
```bash
# Install Velero
velero install \
  --provider alibaba \
  --bucket vhr-k8s-backup \
  --secret-file ./cloud-credentials

# Create backup
velero backup create vhr-prod-backup --include-namespaces vhr-prod

# View backups
velero backup get

# Restore backup
velero restore create --from-backup vhr-prod-backup
```

### 3. Disaster Recovery

#### Switch to Secondary Cluster
```bash
# 1. Verify primary cluster status
kubectl get nodes --context=prod-primary

# 2. Switch DNS to secondary
aliyun alidns UpdateDomainRecord \
  --RecordId ${primary_record_id} \
  --Weight 0

aliyun alidns UpdateDomainRecord \
  --RecordId ${secondary_record_id} \
  --Weight 100

# 3. Verify secondary cluster services
kubectl get pods --context=prod-secondary -n vhr-prod

# 4. Monitor switchover effect
watch -n 5 'curl -s -o /dev/null -w "%{http_code}\n" https://vhr.example.com'
```

---

## Quick Command Reference

### Common kubectl Commands
```bash
# Resource viewing
kubectl get all -n vhr-prod
kubectl describe <resource> <name> -n vhr-prod
kubectl logs <pod> -n vhr-prod

# Resource operations
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
kubectl edit <resource> <name> -n vhr-prod

# Debugging
kubectl exec -it <pod> -n vhr-prod -- sh
kubectl port-forward svc/<service> 8080:80 -n vhr-prod

# Resource quotas
kubectl top nodes
kubectl top pods -n vhr-prod
kubectl describe resourcequota -n vhr-prod
```

### Common Helm Commands
```bash
helm install <name> <chart> -n <namespace>
helm upgrade <name> <chart> -n <namespace>
helm rollback <name> <revision> -n <namespace>
helm uninstall <name> -n <namespace>
helm list -n <namespace>
helm history <name> -n <namespace>
```

### Common Alibaba Cloud CLI Commands
```bash
# ECS
aliyun ecs DescribeInstances
aliyun ecs RebootInstance --InstanceId <id>

# RDS
aliyun rds DescribeDBInstances
aliyun rds CreateBackup --DBInstanceId <id>

# SLB
aliyun slb DescribeLoadBalancers
aliyun slb DescribeLoadBalancerAttribute --LoadBalancerId <id>

# ACK
aliyun cs DescribeClusters
aliyun cs DescribeClusterNodes --ClusterId <id>
```

---

## Contact Information

### Emergency Contacts
- **Operations On-Call**: 138-xxxx-xxxx
- **DBA**: 139-xxxx-xxxx
- **Architect**: 137-xxxx-xxxx

### Related Links
- Grafana: https://grafana.vhr.example.com
- Prometheus: https://prometheus.vhr.example.com
- Alibaba Cloud Console: https://.console.aliyun.com
- Log Service: https://sls.console.aliyun.com
