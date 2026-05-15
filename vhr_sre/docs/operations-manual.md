# VHR 运维手册

## 目录
- [日常运维](#日常运维)
- [故障排查](#故障排查)
- [部署操作](#部署操作)
- [监控告警](#监控告警)
- [安全运维](#安全运维)
- [备份恢复](#备份恢复)

---

## 日常运维

### 1. 集群健康检查

#### Kubernetes 集群状态
```bash
# 检查节点状态
kubectl get nodes -o wide

# 检查节点资源使用
kubectl top nodes

# 检查集群组件状态
kubectl get cs

# 检查所有 Pod 状态
kubectl get pods --all-namespaces

# 检查异常 Pod
kubectl get pods --all-namespaces --field-selector=status.phase!=Running
```

#### Frontend 应用状态
```bash
# 检查 Frontend Deployment
kubectl get deployment vhr-frontend -n vhr-prod

# 检查 Pod 详情
kubectl describe deployment vhr-frontend -n vhr-prod

# 查看日志
kubectl logs -l app.kubernetes.io/name=vhr-frontend -n vhr-prod --tail=100

# 实时查看日志
kubectl logs -f -l app.kubernetes.io/name=vhr-frontend -n vhr-prod
```

### 2. 资源使用监控

```bash
# Pod 资源使用
kubectl top pods -n vhr-prod

# 容器资源使用
kubectl top pods -n vhr-prod --containers

# 查看资源限制
kubectl get pods -n vhr-prod -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}'
```

### 3. 日志查看

#### K8s 应用日志
```bash
# 查看最近日志
kubectl logs deployment/vhr-frontend -n vhr-prod --tail=200

# 查看特定时间范围
kubectl logs deployment/vhr-frontend -n vhr-prod --since=1h

# 多容器日志
kubectl logs deployment/vhr-frontend -n vhr-prod --all-containers

# 导出日志到文件
kubectl logs deployment/vhr-frontend -n vhr-prod > frontend.log
```

#### 阿里云 SLS 日志
```
1. 登录阿里云控制台
2. 进入日志服务
3. 选择 vhr-prod project
4. 查询示例:
   - 错误日志: level: ERROR
   - 慢请求: request_time > 1
   - 特定接口: path: "/api/user/*"
```

---

## 故障排查

### 1. Pod 故障

#### Pod 一直处于 Pending 状态
```bash
# 查看事件
kubectl describe pod <pod-name> -n vhr-prod

# 常见原因:
# - 资源不足: 检查节点资源
# - PVC 未绑定: 检查 PV/PVC
# - 节点选择器不匹配: 检查 nodeSelector/affinity

# 解决方案:
kubectl top nodes  # 检查节点资源
kubectl get pvc -n vhr-prod  # 检查 PVC 状态
```

#### Pod 一直处于 CrashLoopBackOff
```bash
# 查看日志
kubectl logs <pod-name> -n vhr-prod --previous

# 查看事件
kubectl describe pod <pod-name> -n vhr-prod

# 常见原因:
# - 应用启动失败: 检查应用日志
# - 健康检查失败: 检查 liveness/readiness probe
# - 资源不足: 增加资源限制

# 临时调试
kubectl run debug --rm -it --image=busybox -n vhr-prod -- sh
```

#### Pod 重启次数过多
```bash
# 查看重启次数
kubectl get pod <pod-name> -n vhr-prod -o jsonpath='{.status.containerStatuses[0].restartCount}'

# 查看上一次日志
kubectl logs <pod-name> -n vhr-prod --previous
```

### 2. 网络故障

#### Service 无法访问
```bash
# 检查 Service
kubectl get svc -n vhr-prod
kubectl describe svc vhr-frontend -n vhr-prod

# 检查 Endpoints
kubectl get endpoints vhr-frontend -n vhr-prod

# 测试服务连通性
kubectl run curl-test --rm -it --image=curlimages/curl -n vhr-prod -- \
  curl http://vhr-frontend.vhr-prod.svc.cluster.local
```

#### Ingress 无法访问
```bash
# 检查 Ingress
kubectl get ingress -n vhr-prod
kubectl describe ingress vhr-frontend -n vhr-prod

# 检查 Ingress Controller
kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx

# 检查 SLB
aliyun slb DescribeLoadBalancerAttribute --LoadBalancerId <slb-id>
```

### 3. 性能问题

#### 应用响应慢
```bash
# 检查 Pod 资源使用
kubectl top pod <pod-name> -n vhr-prod

# 检查 HPA 状态
kubectl get hpa -n vhr-prod

# 查看应用指标 (Prometheus)
# 查询: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

#### 内存泄漏
```bash
# 监控内存增长
watch -n 5 'kubectl top pod <pod-name> -n vhr-prod'

# 导出堆内存分析
kubectl exec <pod-name> -n vhr-prod -- jmap -dump:live,format=b,file=/tmp/heap.hprof 1
kubectl cp vhr-prod/<pod-name>:/tmp/heap.hprof ./heap.hprof
```

---

## 部署操作

### 1. Helm 部署

#### 部署新版本
```bash
# 查看当前版本
helm list -n vhr-prod

# 部署新版本
helm upgrade vhr-frontend ./vhr_sre/helm/vhr-frontend \
  -f ./vhr_sre/helm/vhr-frontend/values-prod.yaml \
  --namespace vhr-prod \
  --set image.tag=v1.2.3 \
  --wait

# 查看部署状态
helm status vhr-frontend -n vhr-prod

# 查看历史版本
helm history vhr-frontend -n vhr-prod
```

#### 回滚部署
```bash
# 查看历史版本
helm history vhr-frontend -n vhr-prod

# 回滚到指定版本
helm rollback vhr-frontend 2 -n vhr-prod

# 验证回滚
helm status vhr-frontend -n vhr-prod
kubectl get pods -l app.kubernetes.io/name=vhr-frontend -n vhr-prod
```

### 2. 扩缩容

#### 手动扩容
```bash
# 扩容到 5 个副本
kubectl scale deployment vhr-frontend -n vhr-prod --replicas=5

# 查看状态
kubectl get deployment vhr-frontend -n vhr-prod
```

#### 自动扩容配置
```bash
# 检查 HPA
kubectl get hpa vhr-frontend -n vhr-prod

# 更新 HPA 配置
kubectl autoscale deployment vhr-frontend -n vhr-prod \
  --min=3 --max=10 --cpu-percent=80
```

---

## 监控告警

### 1. Prometheus 查询

#### 常用查询语句
```promql
# 请求速率
rate(http_requests_total[5m])

# 错误率
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ sum(rate(http_requests_total[5m]))

# P95 延迟
histogram_quantile(0.95, 
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)

# Pod 内存使用
container_memory_usage_bytes{namespace="vhr-prod"}

# Pod CPU 使用
rate(container_cpu_usage_seconds_total{namespace="vhr-prod"}[5m])
```

### 2. Grafana 仪表盘

#### 访问 Grafana
```bash
# 端口转发访问
kubectl port-forward svc/grafana -n monitoring 3000:80

# 浏览器访问
http://localhost:3000
# 用户名: admin
# 密码: admin (首次登录后修改)
```

#### 导入仪表盘
```
常用仪表盘 ID:
- 315: Kubernetes cluster monitoring
- 6417: Kubernetes pods
- 1860: Node Exporter Full
- 7249: NGINX Ingress controller
```

### 3. 告警处理

#### 查看告警
```bash
# 访问 Alertmanager UI
kubectl port-forward svc/alertmanager-operated -n monitoring 9093:9093

# 浏览器访问
http://localhost:9093
```

#### 告警分级
| 级别 | 响应时间 | 通知方式 | 示例 |
|------|---------|---------|------|
| Critical | 5分钟 | 电话 + 钉钉 | 服务不可用、数据丢失 |
| Warning | 30分钟 | 钉钉 + 邮件 | 高延迟、高错误率 |
| Info | 4小时 | 邮件 | 容量预警 |

---

## 安全运维

### 1. 访问控制

#### RBAC 配置
```bash
# 查看角色
kubectl get roles,rolebindings -n vhr-prod

# 查看集群角色
kubectl get clusterroles,clusterrolebindings

# 创建命名空间管理员
kubectl create rolebinding dev-admin \
  --clusterrole=admin \
  --user=dev@example.com \
  -n vhr-dev
```

#### ServiceAccount 管理
```bash
# 查看 ServiceAccount
kubectl get serviceaccounts -n vhr-prod

# 创建新 ServiceAccount
kubectl create serviceaccount vhr-deployer -n vhr-prod
```

### 2. 安全扫描

#### 镜像漏洞扫描
```bash
# 使用 Trivy 扫描
trivy image registry.cn-beijing.aliyuncs.com/vhr/frontend:v1.2.3

# 扫描结果处理:
# - Critical: 立即修复
# - High: 24小时内修复
# - Medium: 7天内修复
```

### 3. 密钥管理

#### Secret 管理
```bash
# 查看 Secret
kubectl get secrets -n vhr-prod

# 创建 Secret
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=xxx \
  -n vhr-prod

# 更新 Secret
kubectl create secret generic db-credentials \
  --from-literal=password=newpassword \
  -n vhr-prod --dry-run=client -o yaml | kubectl apply -f -
```

---

## 备份恢复

### 1. 数据备份

#### 数据库备份
```bash
# RDS 自动备份 (阿里云控制台)
# 每日凌晨 2:00 自动备份
# 保留 7 天

# 手动备份
aliyun rds CreateBackup --DBInstanceId <instance-id>

# 备份下载
aliyun rds DescribeBackups --DBInstanceId <instance-id>
```

#### Redis 备份
```bash
# Redis 集群版自动备份
# 控制台配置: 每日备份，保留 7 天
```

### 2. K8s 资源备份

#### 使用 Velero 备份
```bash
# 安装 Velero
velero install \
  --provider alibaba \
  --bucket vhr-k8s-backup \
  --secret-file ./cloud-credentials

# 创建备份
velero backup create vhr-prod-backup --include-namespaces vhr-prod

# 查看备份
velero backup get

# 恢复备份
velero restore create --from-backup vhr-prod-backup
```

### 3. 灾难恢复

#### 切换到备集群
```bash
# 1. 验证主集群状态
kubectl get nodes --context=prod-primary

# 2. 切换 DNS 到备集群
aliyun alidns UpdateDomainRecord \
  --RecordId ${primary_record_id} \
  --Weight 0

aliyun alidns UpdateDomainRecord \
  --RecordId ${secondary_record_id} \
  --Weight 100

# 3. 验证备集群服务
kubectl get pods --context=prod-secondary -n vhr-prod

# 4. 监控切换效果
watch -n 5 'curl -s -o /dev/null -w "%{http_code}\n" https://vhr.example.com'
```

---

## 常用命令速查

### kubectl 常用命令
```bash
# 资源查看
kubectl get all -n vhr-prod
kubectl describe <resource> <name> -n vhr-prod
kubectl logs <pod> -n vhr-prod

# 资源操作
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
kubectl edit <resource> <name> -n vhr-prod

# 调试
kubectl exec -it <pod> -n vhr-prod -- sh
kubectl port-forward svc/<service> 8080:80 -n vhr-prod

# 资源配额
kubectl top nodes
kubectl top pods -n vhr-prod
kubectl describe resourcequota -n vhr-prod
```

### Helm 常用命令
```bash
helm install <name> <chart> -n <namespace>
helm upgrade <name> <chart> -n <namespace>
helm rollback <name> <revision> -n <namespace>
helm uninstall <name> -n <namespace>
helm list -n <namespace>
helm history <name> -n <namespace>
```

### 阿里云 CLI 常用命令
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

## 联系方式

### 紧急联系
- **运维值班**: 138-xxxx-xxxx
- **DBA**: 139-xxxx-xxxx
- **架构师**: 137-xxxx-xxxx

### 相关链接
- Grafana: https://grafana.vhr.example.com
- Prometheus: https://prometheus.vhr.example.com
- 阿里云控制台: https://.console.aliyun.com
- 日志服务: https://sls.console.aliyun.com
