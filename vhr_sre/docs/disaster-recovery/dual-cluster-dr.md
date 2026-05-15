# Same-City Dual-Cluster Disaster Recovery Solution

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│              Alibaba Cloud Beijing Region                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐          ┌──────────────────┐        │
│  │   Zone A          │          │   Zone B          │        │
│  ├──────────────────┤          ├──────────────────┤        │
│  │                  │          │                  │        │
│  │  ┌────────────┐  │          │  ┌────────────┐  │        │
│  │  │ Primary    │  │          │  │ Secondary  │  │        │
│  │  │ Cluster    │  │          │  │ Cluster    │  │        │
│  │  │            │  │          │  │            │  │        │
│  │  │ Frontend   │──┼──────────┼──│ Frontend   │  │        │
│  │  │ Backend    │  │   Sync   │  │ Backend    │  │        │
│  │  │ Worker     │  │          │  │ Worker     │  │        │
│  │  └────────────┘  │          │  └────────────┘  │        │
│  │                  │          │                  │        │
│  │  ┌────────────┐  │          │  ┌────────────┐  │        │
│  │  │ RDS Master │──┼──────────┼──│ RDS Read   │  │        │
│  │  └────────────┘  │  Replication│ └────────────┘  │        │
│  │                  │          │                  │        │
│  └──────────────────┘          └──────────────────┘        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                  GSLB / DNS Load Balancer            │  │
│  │        Auto Failover (Primary ⇄ Secondary)           │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Disaster Recovery Metrics

| Metric | Primary Failure | Secondary Failure | Region Failure |
|--------|----------------|-------------------|----------------|
| RTO (Recovery Time) | 1-5 minutes | No impact | N/A |
| RPO (Data Loss) | 0-1 minute | 0 | N/A |
| Service Availability | 99.95% | 99.99% | Requires cross-region |

## Implementation Solution

### 1. Cluster Configuration

#### Primary Cluster
- **Location**: Zone A
- **Purpose**: Production traffic
- **Nodes**: 3+ Worker Nodes
- **Services**: All services running

#### Secondary Cluster
- **Location**: Zone B
- **Purpose**: Disaster recovery backup
- **Nodes**: 2+ Worker Nodes (elastic scaling)
- **Services**: Critical services always-on + others on-demand

### 2. Data Synchronization

#### Database Layer
- **RDS Master-Slave Sync**: Real-time sync to secondary zone
- **Redis Cluster**: Cross-zone master-slave
- **OSS**: Alibaba Cloud auto cross-zone replication

#### Application Layer
- **Container Images**: ACR unified image registry
- **Configuration**: GitOps sync (ArgoCD/Flux)
- **State Data**: Stateless design, state in external services

### 3. Traffic Switching

#### DNS/GSLB Configuration
```yaml
# Alibaba Cloud DNS configuration example
vhr.example.com:
  - Primary Record: Primary cluster SLB IP (weight 100)
  - Secondary Record: Secondary cluster SLB IP (weight 0)
  
Failover:
  - Health check failure → Weight switch (0/100)
  - Auto switch time: 30-60 seconds
```

#### Ingress Configuration
```yaml
# Primary Cluster Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vhr-frontend
  annotations:
    nginx.ingress.kubernetes.io/canary: "false"
spec:
  rules:
  - host: vhr.example.com
```

### 4. Failover Process

#### Automatic Failover (Recommended)
```
1. Health check detects primary cluster failure (30s)
2. GSLB auto-switches to secondary (30s)
3. Secondary cluster scales to production size (2-5min)
4. Traffic routes to secondary cluster
```

#### Manual Failover
```bash
# 1. Verify primary cluster status
kubectl get nodes --context=primary-cluster

# 2. Switch DNS weights
aliyun alidns UpdateDomainRecord \
  --RecordId xxx \
  --Weight 0  # Set primary weight to 0

# 3. Scale secondary cluster
kubectl scale deployment vhr-frontend \
  --replicas=3 \
  --context=secondary-cluster

# 4. Verify secondary cluster services
kubectl get pods --context=secondary-cluster
```

### 5. Data Consistency Assurance

#### Database Disaster Recovery
```hcl
# RDS Primary Instance (Primary Zone)
resource "alicloud_db_instance" "primary" {
  zone_id = "cn-beijing-a"
  # ...
}

# RDS Read-Only Instance (Secondary Zone)
resource "alicloud_db_readonly_instance" "secondary" {
  zone_id = "cn-beijing-b"
  source_db_instance_id = alicloud_db_instance.primary.id
  # ...
}
```

#### Redis Disaster Recovery
```hcl
# Redis Cluster Edition (Cross-Zone)
resource "alicloud_kvstore_instance" "redis" {
  engine_version = "5.0"
  architecture_type = "cluster"
  # Auto cross-zone high availability
}
```

### 6. Monitoring & Alerting

#### Key Metrics
- Cluster health status
- Node availability rate
- Pod restart count
- Application response time
- Database replication lag

#### Alert Rules
```yaml
# Prometheus alert rules example
groups:
- name: disaster-recovery
  rules:
  - alert: PrimaryClusterDown
    expr: up{cluster="primary"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Primary cluster unavailable, triggering DR failover"
      
  - alert: DBReplicationLag
    expr: mysql_replication_lag_seconds > 60
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "Database replication lag too high"
```

### 7. Drill Plan

#### Regular Drills
- **Frequency**: Quarterly
- **Scope**: Non-prod environment → Production
- **Goal**: Validate RTO/RPO metrics

#### Drill Steps
```
1. Simulate primary cluster failure (shutdown nodes)
2. Observe auto-failover time
3. Verify data integrity
4. Recover primary cluster
5. Switch back to primary
6. Summarize drill results
```

### 8. Cost Estimation

| Resource | Primary Cluster | Secondary Cluster | Monthly Cost Est. |
|----------|----------------|-------------------|-------------------|
| ACK Control Plane | Free | Free | ¥0 |
| Worker Nodes | 3 × ecs.c6.large | 2 × ecs.c6.large | ~¥1,500 |
| RDS | Primary Instance | Read-Only Instance | ~¥2,000 |
| Redis | Cluster Edition | - | ~¥800 |
| SLB | 2 instances | 2 instances | ~¥200 |
| **Total** | | | **~¥4,500/month** |

## Best Practices

### 1. Application Design
- ✅ Stateless design
- ✅ Externalized configuration (ConfigMap/Secret)
- ✅ Health check endpoints
- ✅ Graceful shutdown

### 2. Deployment Strategy
- ✅ GitOps unified management
- ✅ Unified image versions
- ✅ Environment isolation
- ✅ Progressive release

### 3. Data Management
- ✅ Regular backups
- ✅ Backup verification
- ✅ Encrypted storage
- ✅ Access control

### 4. Operations Standards
- ✅ Change approval process
- ✅ Rollback plan
- ✅ Monitoring coverage
- ✅ Documentation updates
