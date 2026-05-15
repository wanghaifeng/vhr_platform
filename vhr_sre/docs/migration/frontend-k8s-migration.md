# Frontend Migration to Kubernetes Guide

## Architecture Changes

### Before Migration
| Component | Location | Count | Description |
|-----------|----------|-------|-------------|
| Frontend | ECS | 2 × ecs.c6.2xlarge | Nginx + Vue.js |
| Backend | ECS | 4 × ecs.c6.2xlarge | Spring Boot |
| SLB | Standalone | slb.s3.large | Points to Frontend ECS |

### After Migration
| Component | Location | Count | Description |
|-----------|----------|-------|-------------|
| Frontend | K8s Pod | 3+ Pods | Nginx container |
| Backend | ECS | 4 × ecs.c6.2xlarge | Unchanged |
| Ingress | K8s Ingress | Auto SLB | K8s managed |
| Backup SLB | Standalone | slb.s2.large | Points to Backend ECS |

## Cost Comparison

| Item | Before | After | Savings |
|------|--------|-------|---------|
| Frontend ECS | 2 × ¥1,200 = ¥2,400 | 0 | ¥2,400 |
| K8s Nodes | 0 | 3 × ¥600 = ¥1,800 | -¥1,800 |
| Main SLB | ¥300 (s3.large) | ¥150 (s2.large) | ¥150 |
| Ingress SLB | 0 | ¥100 | -¥100 |
| **Monthly Savings** | | | **¥650/month** |

## Migration Steps

### Phase 1: Preparation (No Production Impact)

#### 1.1 Create K8s Cluster
```bash
# Apply K8s cluster configuration
cd vhr_sre/infrastructure/environments/prod
terraform apply -target=module.ack
```

#### 1.2 Configure kubectl
```bash
# Get cluster credentials
aliyun cs GET /k8s/${cluster_id}/user_config > ~/.kube/config-prod

# Verify connection
kubectl get nodes --context=prod
```

#### 1.3 Install Ingress Controller
```bash
# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/alibaba-cloud-loadbalancer-spec"="slb.s3.large"
```

#### 1.4 Configure Container Registry Credentials
```bash
# Create Docker Registry Secret
kubectl create secret docker-registry aliyun-registry \
  --docker-server=registry.cn-beijing.aliyuncs.com \
  --docker-username=${ALIBABA_CLOUD_USERNAME} \
  --docker-password=${ALIBABA_CLOUD_PASSWORD} \
  --namespace vhr-prod
```

### Phase 2: Test Deployment (Non-Production Traffic)

#### 2.1 Deploy Frontend to K8s
```bash
# Deploy to test namespace
helm install vhr-frontend-test ./vhr_sre/helm/vhr-frontend \
  -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml \
  --namespace vhr-test \
  --create-namespace
```

#### 2.2 Verify Deployment
```bash
# Check Pod status
kubectl get pods -n vhr-test -l app.kubernetes.io/name=vhr-frontend

# Check Service
kubectl get svc -n vhr-test

# Check Ingress
kubectl get ingress -n vhr-test

# Test access
kubectl port-forward svc/vhr-frontend 8080:80 -n vhr-test
# Access http://localhost:8080
```

#### 2.3 Performance Testing
```bash
# Load testing
ab -n 10000 -c 100 http://vhr-frontend.test.example.com/
```

### Phase 3: Canary Traffic Migration (Gradual Traffic Shift)

#### 3.1 DNS Canary Configuration
```
# Alibaba Cloud DNS configuration
vhr.example.com:
  - Record1: ECS SLB IP (weight 90)  # 90% traffic
  - Record2: K8s Ingress IP (weight 10)  # 10% traffic
```

#### 3.2 Monitor Migration
```bash
# Monitor K8s Frontend metrics
kubectl top pods -n vhr-prod

# Monitor response time
# Prometheus query
avg(response_time_seconds{namespace="vhr-prod"})
```

#### 3.3 Gradually Adjust Weights
```
Day 1: 90% ECS / 10% K8s
Day 2: 70% ECS / 30% K8s
Day 3: 50% ECS / 50% K8s
Day 4: 30% ECS / 70% K8s
Day 5: 10% ECS / 90% K8s
Day 6: 0% ECS / 100% K8s  # Complete switch
```

### Phase 4: Complete Migration

#### 4.1 Stop ECS Frontend
```bash
# Update Terraform configuration
# instance_counts.frontend = 0

terraform apply -target=module.ecs
```

#### 4.2 Release Resources
```bash
# Release Frontend ECS
aliyun ecs StopInstance --instance-id ${frontend_instance_id}
aliyun ecs DeleteInstance --instance-id ${frontend_instance_id}

# Downgrade SLB spec
# Update Terraform: slb_spec = "slb.s2.large"
terraform apply -target=module.slb
```

#### 4.3 Update Documentation
- Update architecture diagrams
- Update operations documentation
- Train team

## Verification Checklist

### Functional Verification
- [ ] Frontend pages accessible
- [ ] API calls working
- [ ] Static resources loading
- [ ] User login/registration working
- [ ] All functional tests passing

### Performance Verification
- [ ] Response time < 200ms
- [ ] Error rate < 0.1%
- [ ] Pod auto-scaling working
- [ ] Load balancing working

### Disaster Recovery Verification
- [ ] K8s node failure auto-recovery
- [ ] Pod failure auto-restart
- [ ] Secondary cluster sync working
- [ ] Failover drill successful

### Monitoring & Alerting
- [ ] Prometheus monitoring working
- [ ] Grafana dashboards working
- [ ] Alert rules active
- [ ] Log collection working

## Rollback Plan

### Quick Rollback to ECS
```bash
# 1. Adjust DNS weights
aliyun alidns UpdateDomainRecord \
  --RecordId ${k8s_record_id} \
  --Weight 0

aliyun alidns UpdateDomainRecord \
  --RecordId ${ecs_record_id} \
  --Weight 100

# 2. Start ECS Frontend
terraform apply -target=module.ecs \
  -var='instance_counts={"frontend":2,"backend":4}'

# 3. Verify
curl -I https://vhr.example.com
```

### Rollback Time Target
- DNS switch: 30-60 seconds
- ECS startup: 2-3 minutes
- Total rollback time: **< 5 minutes**

## Important Notes

### Key Configurations
1. **K8s Resource Limits**: Ensure reasonable requests/limits are set
2. **Health Checks**: Configure correct liveness/readiness probes
3. **Auto-scaling**: Configure HPA policies
4. **Logging**: Ensure logs output to stdout/stderr

### Common Issues
1. **Image pull failure**: Check imagePullSecrets configuration
2. **Pod won't start**: Check resource limits and node resources
3. **Access timeout**: Check Ingress and Service configuration
4. **Configuration errors**: Use ConfigMap to manage configuration

### Best Practices
1. ✅ Use Helm for deployment management
2. ✅ Version all configurations
3. ✅ Implement gradual releases
4. ✅ Maintain rollback capability
5. ✅ Continuously monitor and optimize
