# Frontend 迁移到 Kubernetes 指南

## 架构变化

### 迁移前
| 组件 | 位置 | 数量 | 说明 |
|------|------|------|------|
| Frontend | ECS | 2 × ecs.c6.2xlarge | Nginx + Vue.js |
| Backend | ECS | 4 × ecs.c6.2xlarge | Spring Boot |
| SLB | 独立 | slb.s3.large | 指向 Frontend ECS |

### 迁移后
| 组件 | 位置 | 数量 | 说明 |
|------|------|------|------|
| Frontend | K8s Pod | 3+ Pods | Nginx 容器 |
| Backend | ECS | 4 × ecs.c6.2xlarge | 保持不变 |
| Ingress | K8s Ingress | 自动 SLB | K8s 管理 |
| 备用 SLB | 独立 | slb.s2.large | 指向 Backend ECS |

## 成本对比

| 项目 | 迁移前 | 迁移后 | 节省 |
|------|--------|--------|------|
| Frontend ECS | 2 × ¥1,200 = ¥2,400 | 0 | ¥2,400 |
| K8s 节点 | 0 | 3 × ¥600 = ¥1,800 | -¥1,800 |
| 主 SLB | ¥300 (s3.large) | ¥150 (s2.large) | ¥150 |
| Ingress SLB | 0 | ¥100 | -¥100 |
| **月节省** | | | **¥650/月** |

## 迁移步骤

### 阶段 1: 准备阶段 (不影响生产)

#### 1.1 创建 K8s 集群
```bash
# 应用 K8s 集群配置
cd vhr_sre/infrastructure/environments/prod
terraform apply -target=module.ack
```

#### 1.2 配置 kubectl
```bash
# 获取集群凭证
aliyun cs GET /k8s/${cluster_id}/user_config > ~/.kube/config-prod

# 验证连接
kubectl get nodes --context=prod
```

#### 1.3 安装 Ingress Controller
```bash
# 安装 NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/alibaba-cloud-loadbalancer-spec"="slb.s3.large"
```

#### 1.4 配置容器镜像仓库凭证
```bash
# 创建 Docker Registry Secret
kubectl create secret docker-registry aliyun-registry \
  --docker-server=registry.cn-beijing.aliyuncs.com \
  --docker-username=${ALIBABA_CLOUD_USERNAME} \
  --docker-password=${ALIBABA_CLOUD_PASSWORD} \
  --namespace vhr-prod
```

### 阶段 2: 测试部署 (非生产流量)

#### 2.1 部署 Frontend 到 K8s
```bash
# 部署到测试命名空间
helm install vhr-frontend-test ./vhr_sre/helm/vhr-frontend \
  -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml \
  --namespace vhr-test \
  --create-namespace
```

#### 2.2 验证部署
```bash
# 检查 Pod 状态
kubectl get pods -n vhr-test -l app.kubernetes.io/name=vhr-frontend

# 检查 Service
kubectl get svc -n vhr-test

# 检查 Ingress
kubectl get ingress -n vhr-test

# 测试访问
kubectl port-forward svc/vhr-frontend 8080:80 -n vhr-test
# 访问 http://localhost:8080
```

#### 2.3 性能测试
```bash
# 压力测试
ab -n 10000 -c 100 http://vhr-frontend.test.example.com/
```

### 阶段 3: 灰度切换 (逐步迁移流量)

#### 3.1 DNS 灰度配置
```
# 阿里云 DNS 配置
vhr.example.com:
  - 记录1: ECS SLB IP (权重 90)  # 90% 流量
  - 记录2: K8s Ingress IP (权重 10)  # 10% 流量
```

#### 3.2 监控切换
```bash
# 监控 K8s Frontend 指标
kubectl top pods -n vhr-prod

# 监控响应时间
# Prometheus 查询
avg(response_time_seconds{namespace="vhr-prod"})
```

#### 3.3 逐步调整权重
```
第1天: 90% ECS / 10% K8s
第2天: 70% ECS / 30% K8s
第3天: 50% ECS / 50% K8s
第4天: 30% ECS / 70% K8s
第5天: 10% ECS / 90% K8s
第6天: 0% ECS / 100% K8s  # 完全切换
```

### 阶段 4: 完成迁移

#### 4.1 停止 ECS Frontend
```bash
# 更新 Terraform 配置
# instance_counts.frontend = 0

terraform apply -target=module.ecs
```

#### 4.2 释放资源
```bash
# 释放 Frontend ECS
aliyun ecs StopInstance --instance-id ${frontend_instance_id}
aliyun ecs DeleteInstance --instance-id ${frontend_instance_id}

# 降低 SLB 规格
# 更新 Terraform: slb_spec = "slb.s2.large"
terraform apply -target=module.slb
```

#### 4.3 更新文档
- 更新架构图
- 更新运维文档
- 培训团队

## 验证清单

### 功能验证
- [ ] Frontend 页面正常访问
- [ ] API 调用正常
- [ ] 静态资源加载正常
- [ ] 用户登录/注册正常
- [ ] 所有功能测试通过

### 性能验证
- [ ] 响应时间 < 200ms
- [ ] 错误率 < 0.1%
- [ ] Pod 自动扩缩容正常
- [ ] 负载均衡正常

### 容灾验证
- [ ] K8s 节点故障自动恢复
- [ ] Pod 故障自动重启
- [ ] 备集群同步正常
- [ ] 故障切换演练成功

### 监控告警
- [ ] Prometheus 监控正常
- [ ] Grafana 仪表盘正常
- [ ] 告警规则生效
- [ ] 日志采集正常

## 回滚方案

### 快速回滚到 ECS
```bash
# 1. 调整 DNS 权重
aliyun alidns UpdateDomainRecord \
  --RecordId ${k8s_record_id} \
  --Weight 0

aliyun alidns UpdateDomainRecord \
  --RecordId ${ecs_record_id} \
  --Weight 100

# 2. 启动 ECS Frontend
terraform apply -target=module.ecs \
  -var='instance_counts={"frontend":2,"backend":4}'

# 3. 验证
curl -I https://vhr.example.com
```

### 回滚时间目标
- DNS 切换: 30-60秒
- ECS 启动: 2-3分钟
- 总回滚时间: **< 5分钟**

## 注意事项

### 关键配置
1. **K8s 资源限制**: 确保设置了合理的 requests/limits
2. **健康检查**: 配置正确的 liveness/readiness probe
3. **自动伸缩**: 配置 HPA 策略
4. **日志**: 确保日志输出到 stdout/stderr

### 常见问题
1. **镜像拉取失败**: 检查 imagePullSecrets 配置
2. **Pod 无法启动**: 检查资源限制和节点资源
3. **访问超时**: 检查 Ingress 和 Service 配置
4. **配置错误**: 使用 ConfigMap 管理配置

### 最佳实践
1. ✅ 使用 Helm 管理部署
2. ✅ 版本化所有配置
3. ✅ 实施渐进式发布
4. ✅ 保持回滚能力
5. ✅ 持续监控和优化
