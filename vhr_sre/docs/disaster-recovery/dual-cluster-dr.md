# 同城双集群容灾方案

## 架构概述

```
┌─────────────────────────────────────────────────────────────┐
│                      阿里云 北京地域                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐          ┌──────────────────┐        │
│  │   可用区 A        │          │   可用区 B        │        │
│  ├──────────────────┤          ├──────────────────┤        │
│  │                  │          │                  │        │
│  │  ┌────────────┐  │          │  ┌────────────┐  │        │
│  │  │ 主集群     │  │          │  │ 备集群     │  │        │
│  │  │ (Primary)  │  │          │  │ (Secondary)│  │        │
│  │  │            │  │          │  │            │  │        │
│  │  │ Frontend   │──┼──────────┼──│ Frontend   │  │        │
│  │  │ Backend    │  │   同步   │  │ Backend    │  │        │
│  │  │ Worker     │  │          │  │ Worker     │  │        │
│  │  └────────────┘  │          │  └────────────┘  │        │
│  │                  │          │                  │        │
│  │  ┌────────────┐  │          │  ┌────────────┐  │        │
│  │  │ RDS 主库   │──┼──────────┼──│ RDS 只读   │  │        │
│  │  └────────────┘  │  主从同步 │  └────────────┘  │        │
│  │                  │          │                  │        │
│  └──────────────────┘          └──────────────────┘        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                  GSLB / DNS 负载均衡                 │  │
│  │        自动故障切换 (主集群 ⇄ 备集群)                  │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 容灾指标

| 指标 | 主集群故障 | 备集群故障 | 地域故障 |
|------|-----------|-----------|---------|
| RTO (恢复时间) | 1-5 分钟 | 无影响 | 不适用 |
| RPO (数据丢失) | 0-1 分钟 | 0 | 不适用 |
| 服务可用性 | 99.95% | 99.99% | 需跨地域方案 |

## 实现方案

### 1. 集群配置

#### 主集群 (Primary)
- **位置**: 可用区 A
- **用途**: 承载生产流量
- **节点**: 3+ Worker Nodes
- **服务**: 全部服务运行

#### 备集群 (Secondary)
- **位置**: 可用区 B
- **用途**: 容灾备份
- **节点**: 2+ Worker Nodes (可弹性扩展)
- **服务**: 关键服务常驻 + 其他服务按需启动

### 2. 数据同步

#### 数据库层
- **RDS 主从同步**: 实时同步到备可用区
- **Redis 集群**: 跨可用区主从
- **OSS**: 阿里云自动跨可用区复制

#### 应用层
- **容器镜像**: ACR 统一镜像仓库
- **配置**: GitOps 同步 (ArgoCD/Flux)
- **状态数据**: 无状态设计，状态存外部服务

### 3. 流量切换

#### DNS/GSLB 配置
```yaml
# 阿里云 DNS 配置示例
vhr.example.com:
  - 主记录: 主集群 SLB IP (权重 100)
  - 备记录: 备集群 SLB IP (权重 0)
  
故障切换:
  - 健康检查失败 → 权重切换 (0/100)
  - 自动切换时间: 30-60秒
```

#### Ingress 配置
```yaml
# 主集群 Ingress
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

### 4. 故障切换流程

#### 自动切换 (推荐)
```
1. 健康检查检测主集群故障 (30秒)
2. GSLB 自动切换到备集群 (30秒)
3. 备集群扩容到生产规模 (2-5分钟)
4. 流量路由到备集群
```

#### 手动切换
```bash
# 1. 验证主集群状态
kubectl get nodes --context=primary-cluster

# 2. 切换 DNS 权重
aliyun alidns UpdateDomainRecord \
  --RecordId xxx \
  --Weight 0  # 主集群权重设为0

# 3. 扩容备集群
kubectl scale deployment vhr-frontend \
  --replicas=3 \
  --context=secondary-cluster

# 4. 验证备集群服务
kubectl get pods --context=secondary-cluster
```

### 5. 数据一致性保障

#### 数据库容灾
```hcl
# RDS 主实例 (主可用区)
resource "alicloud_db_instance" "primary" {
  zone_id = "cn-beijing-a"
  # ...
}

# RDS 只读实例 (备可用区)
resource "alicloud_db_readonly_instance" "secondary" {
  zone_id = "cn-beijing-b"
  source_db_instance_id = alicloud_db_instance.primary.id
  # ...
}
```

#### Redis 容灾
```hcl
# Redis 集群版 (跨可用区)
resource "alicloud_kvstore_instance" "redis" {
  engine_version = "5.0"
  architecture_type = "cluster"
  # 自动跨可用区高可用
}
```

### 6. 监控与告警

#### 关键指标
- 集群健康状态
- 节点可用率
- Pod 重启次数
- 应用响应时间
- 数据库同步延迟

#### 告警规则
```yaml
# Prometheus 告警规则示例
groups:
- name: disaster-recovery
  rules:
  - alert: PrimaryClusterDown
    expr: up{cluster="primary"} == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "主集群不可用，触发容灾切换"
      
  - alert: DBReplicationLag
    expr: mysql_replication_lag_seconds > 60
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "数据库复制延迟过高"
```

### 7. 演练计划

#### 定期演练
- **频率**: 每季度一次
- **范围**: 非生产环境 → 生产环境
- **目标**: 验证 RTO/RPO 指标

#### 演练步骤
```
1. 模拟主集群故障 (关闭节点)
2. 观察自动切换时间
3. 验证数据完整性
4. 恢复主集群
5. 切换回主集群
6. 总结演练结果
```

### 8. 成本估算

| 资源 | 主集群 | 备集群 | 月成本估算 |
|------|--------|--------|-----------|
| ACK 控制面 | 免费 | 免费 | ¥0 |
| Worker Nodes | 3 × ecs.c6.large | 2 × ecs.c6.large | ~¥1,500 |
| RDS | 主实例 | 只读实例 | ~¥2,000 |
| Redis | 集群版 | - | ~¥800 |
| SLB | 2 个 | 2 个 | ~¥200 |
| **总计** | | | **~¥4,500/月** |

## 最佳实践

### 1. 应用设计
- ✅ 无状态设计
- ✅ 外部化配置 (ConfigMap/Secret)
- ✅ 健康检查端点
- ✅ 优雅关闭 (Graceful Shutdown)

### 2. 部署策略
- ✅ GitOps 统一管理
- ✅ 镜像版本统一
- ✅ 环境隔离
- ✅ 渐进式发布

### 3. 数据管理
- ✅ 定期备份
- ✅ 备份验证
- ✅ 加密存储
- ✅ 访问控制

### 4. 运维规范
- ✅ 变更审批流程
- ✅ 回滚预案
- ✅ 监控覆盖
- ✅ 文档更新
