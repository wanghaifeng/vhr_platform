# vhr 项目部署文档

## 文档信息

| 项目名称 | vhr (微人事管理系统) |
|---------|-------------------|
| 文档版本 | v1.0 |
| 编写日期 | 2026-05-11 |
| 文档类型 | 部署文档 |

---

## 1. 部署概述

### 1.1 系统架构

vhr 是一个前后端分离的企业人事管理系统，主要包含以下组件：

- **前端**：Vue.js 单页面应用
- **后端**：Spring Boot 微服务（vhr-web + mailserver）
- **数据库**：MySQL 8.0+
- **缓存**：Redis
- **消息队列**：RabbitMQ
- **文件存储**：FastDFS（可选）
- **反向代理**：Nginx

### 1.2 部署方式

本文档支持以下部署方式：

1. **开发环境部署**：适用于本地开发和测试
2. **生产环境部署**：适用于生产环境上线
3. **Docker 容器化部署**：适用于云环境部署（可选）

---

## 2. 环境要求

### 2.1 硬件要求

| 环境 | CPU | 内存 | 磁盘 | 说明 |
|-----|-----|------|------|------|
| 开发环境 | 2核+ | 4GB+ | 20GB+ | 本地开发机器 |
| 测试环境 | 4核+ | 8GB+ | 50GB+ | 测试服务器 |
| 生产环境 | 8核+ | 16GB+ | 100GB+ | 生产服务器 |

### 2.2 软件要求

| 软件名称 | 版本要求 | 必需 | 说明 |
|---------|---------|------|------|
| JDK | 1.8+ | 是 | Java 运行环境 |
| MySQL | 8.0+ | 是 | 关系型数据库 |
| Redis | 5.0+ | 是 | 缓存数据库 |
| RabbitMQ | 3.8+ | 是 | 消息队列 |
| Node.js | 12.0+ | 是 | 前端构建环境 |
| Maven | 3.6+ | 是 | Java 构建工具 |
| Nginx | 1.18+ | 否 | 反向代理（生产环境推荐） |
| FastDFS | 5.0+ | 否 | 文件存储（可选） |

### 2.3 端口要求

| 服务 | 默认端口 | 说明 |
|-----|---------|------|
| vhr-web | 8081 | 主服务端口 |
| mailserver | 8082 | 邮件服务端口 |
| MySQL | 3306 | 数据库端口 |
| Redis | 6379 | 缓存端口 |
| RabbitMQ | 5672 | 消息队列端口 |
| RabbitMQ 管理 | 15672 | RabbitMQ 管理界面 |
| Nginx | 80/443 | 反向代理端口 |

---

## 3. 数据库部署

### 3.1 安装 MySQL

**Windows 环境：**

1. 下载 MySQL 8.0+ 安装包：https://dev.mysql.com/downloads/mysql/
2. 运行安装程序，选择 "Developer Default" 安装类型
3. 设置 root 用户密码（建议：生产环境使用强密码）
4. 完成安装并启动 MySQL 服务

**Linux 环境：**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mysql-server

# CentOS/RHEL
sudo yum install mysql-server

# 启动服务
sudo systemctl start mysql
sudo systemctl enable mysql

# 安全配置
sudo mysql_secure_installation
```

### 3.2 创建数据库

```sql
-- 登录 MySQL
mysql -u root -p

-- 创建数据库
CREATE DATABASE vhr DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- 创建用户（可选，生产环境推荐）
CREATE USER 'vhr_user'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON vhr.* TO 'vhr_user'@'%';
FLUSH PRIVILEGES;
```

### 3.3 导入数据库脚本

```bash
# 导入 SQL 文件
mysql -u root -p vhr < D:/Projects/dxyy/vhr/vhr.sql

# 或使用 MySQL 命令行
mysql> use vhr;
mysql> source D:/Projects/dxyy/vhr/vhr.sql;
```

### 3.4 验证数据库

```sql
-- 查看表结构
USE vhr;
SHOW TABLES;

-- 应该看到以下表
-- employee, department, position, joblevel, salary, 
-- adjustsalary, appraise, hr, role, menu, menu_role, 
-- mail_send_log, etc.
```

---

## 4. Redis 部署

### 4.1 安装 Redis

**Windows 环境：**

1. 下载 Redis for Windows：https://github.com/microsoftarchive/redis/releases
2. 解压到指定目录（如：C:\Redis）
3. 修改 `redis.windows.conf` 配置文件：
   ```
   bind 127.0.0.1
   port 6379
   requirepass 123
   ```
4. 启动 Redis 服务：
   ```cmd
   redis-server.exe redis.windows.conf
   ```

**Linux 环境：**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install redis-server

# CentOS/RHEL
sudo yum install redis

# 修改配置文件
sudo vi /etc/redis/redis.conf
# 设置：bind 127.0.0.1
# 设置：requirepass your_password

# 启动服务
sudo systemctl start redis
sudo systemctl enable redis

# 测试连接
redis-cli -a your_password ping
```

### 4.2 验证 Redis

```bash
# 连接 Redis
redis-cli -h 127.0.0.1 -p 6379 -a 123

# 测试命令
127.0.0.1:6379> ping
PONG

127.0.0.1:6379> set test "hello"
OK

127.0.0.1:6379> get test
"hello"
```

---

## 5. RabbitMQ 部署

### 5.1 安装 RabbitMQ

**Windows 环境：**

1. 下载并安装 Erlang：https://www.erlang.org/downloads
2. 下载 RabbitMQ 安装包：https://www.rabbitmq.com/download.html
3. 安装 RabbitMQ
4. 启动管理插件：
   ```cmd
   rabbitmq-plugins enable rabbitmq_management
   ```
5. 访问管理界面：http://localhost:15672（默认账号：guest/guest）

**Linux 环境：**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install rabbitmq-server

# CentOS/RHEL
sudo yum install rabbitmq-server

# 启动服务
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# 启用管理插件
sudo rabbitmq-plugins enable rabbitmq_management

# 添加用户（可选）
sudo rabbitmqctl add_user vhr_user your_password
sudo rabbitmqctl set_user_tags vhr_user administrator
sudo rabbitmqctl set_permissions -p / vhr_user ".*" ".*" ".*"
```

### 5.2 验证 RabbitMQ

```bash
# 查看状态
sudo rabbitmqctl status

# 查看用户列表
sudo rabbitmqctl list_users

# 访问管理界面
# 浏览器打开：http://localhost:15672
# 用户名：guest，密码：guest
```

---

## 6. 后端部署

### 6.1 修改配置文件

配置文件位置：`D:/Projects/dxyy/vhr/vhr/vhrserver/vhr-web/src/main/resources/application.yml`

**主要配置项：**

```yaml
spring:
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    username: root                    # MySQL 用户名
    password: 123                     # MySQL 密码
    url: jdbc:mysql://localhost:3306/vhr?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
    
  rabbitmq:
    username: guest                   # RabbitMQ 用户名
    password: guest                   # RabbitMQ 密码
    host: 127.0.0.1                   # RabbitMQ 主机地址
    publisher-confirms: true
    publisher-returns: true
    
  redis:
    host: 127.0.0.1                   # Redis 主机地址
    database: 0
    port: 6379                        # Redis 端口
    password: 123                     # Redis 密码
    
  cache:
    cache-names: menus_cache
    
server:
  port: 8081                          # 服务端口
  compression:
    enabled: true
    
fastdfs:
  nginx:
    host: http://192.168.91.128/     # FastDFS 地址（可选）
```

**生产环境配置建议：**

```yaml
spring:
  datasource:
    username: vhr_user               # 使用专用数据库用户
    password: strong_password_here   # 使用强密码
    url: jdbc:mysql://your-db-host:3306/vhr?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=true
    
  rabbitmq:
    username: vhr_user               # 使用专用 RabbitMQ 用户
    password: strong_password_here
    host: your-rabbitmq-host
    
  redis:
    host: your-redis-host
    password: strong_password_here
```

### 6.2 构建项目

**方式一：使用 Maven 命令**

```bash
# 进入后端项目目录
cd D:/Projects/dxyy/vhr/vhr/vhrserver

# 清理并打包（跳过测试）
mvn clean package -DskipTests

# 生成的 JAR 包位置：
# vhr-web/target/vhr-web-xxx.jar
```

**方式二：使用 IDE**

1. 使用 IntelliJ IDEA 或 Eclipse 打开项目
2. 右键项目 → Run As → Maven build
3. Goals 输入：`clean package -DskipTests`
4. 点击 Run

### 6.3 启动主服务

**开发环境：**

```bash
# 方式一：直接运行 JAR 包
cd D:/Projects/dxyy/vhr/vhr/vhrserver/vhr-web/target
java -jar vhr-web-1.0.jar

# 方式二：指定配置文件
java -jar vhr-web-1.0.jar --spring.config.location=application.yml

# 方式三：后台运行（Linux）
nohup java -jar vhr-web-1.0.jar > vhr.log 2>&1 &
```

**生产环境（推荐使用 systemd）：**

创建服务文件 `/etc/systemd/system/vhr-web.service`：

```ini
[Unit]
Description=VHR Web Service
After=mysql.service redis.service rabbitmq-server.service

[Service]
Type=simple
User=vhr
WorkingDirectory=/opt/vhr
ExecStart=/usr/bin/java -Xms512m -Xmx1024m -jar /opt/vhr/vhr-web.jar
ExecStop=/bin/kill -15 $MAINPID
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl start vhr-web
sudo systemctl enable vhr-web
sudo systemctl status vhr-web
```

### 6.4 部署邮件服务（可选）

**修改配置文件：**

位置：`D:/Projects/dxyy/vhr/vhr/mailserver/src/main/resources/application.properties`

```properties
# 邮件服务器配置
spring.mail.host=smtp.your-email-provider.com
spring.mail.port=587
spring.mail.username=your-email@example.com
spring.mail.password=your-email-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# RabbitMQ 配置
spring.rabbitmq.host=127.0.0.1
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest

# 服务端口
server.port=8082
```

**构建并启动：**

```bash
cd D:/Projects/dxyy/vhr/vhr/mailserver
mvn clean package -DskipTests
java -jar target/mailserver-1.0.jar
```

### 6.5 验证后端服务

```bash
# 检查服务是否启动
curl http://localhost:8081

# 查看日志
tail -f vhr.log

# 检查端口占用
netstat -an | grep 8081
```

---

## 7. 前端部署

### 7.1 安装依赖

```bash
# 进入前端项目目录
cd D:/Projects/dxyy/vhr/vuehr

# 安装 Node.js 依赖
npm install

# 或使用国内镜像加速
npm install --registry=https://registry.npmmirror.com
```

### 7.2 修改后端 API 地址

修改文件：`D:/Projects/dxyy/vhr/vuehr/src/utils/api.js`

```javascript
// 开发环境
let base = 'http://localhost:8081';

// 生产环境
let base = 'http://your-server-ip:8081';
// 或使用 Nginx 代理
let base = '/api';
```

### 7.3 开发环境运行

```bash
# 启动开发服务器
npm run serve

# 默认访问地址：http://localhost:8080
```

### 7.4 生产环境构建

```bash
# 构建生产版本
npm run build

# 生成的文件在 dist/ 目录
```

构建后的目录结构：

```
dist/
├── index.html           # 入口 HTML
├── css/                 # CSS 文件
│   ├── app.xxx.css
│   └── chunk-xxx.css
├── js/                  # JavaScript 文件
│   ├── app.xxx.js
│   ├── chunk-xxx.js
│   └── ...
└── img/                 # 图片资源
```

### 7.5 部署前端静态文件

**方式一：使用 Nginx（推荐）**

详见第 8 节 Nginx 配置。

**方式二：使用后端静态资源**

将 `dist/` 目录内容复制到后端静态资源目录：

```bash
# Spring Boot 默认静态资源目录
cp -r dist/* D:/Projects/dxyy/vhr/vhr/vhrserver/vhr-web/src/main/resources/static/
```

**方式三：使用独立静态服务器**

```bash
# 使用 serve 工具
npm install -g serve
serve -s dist -p 80

# 使用 http-server 工具
npm install -g http-server
http-server dist -p 80
```

---

## 8. Nginx 配置（生产环境推荐）

### 8.1 安装 Nginx

**Windows 环境：**

1. 下载 Nginx：http://nginx.org/en/download.html
2. 解压到指定目录（如：C:\nginx）
3. 启动 Nginx：
   ```cmd
   cd C:\nginx
   start nginx
   ```

**Linux 环境：**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx

# 启动服务
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 8.2 配置 Nginx

创建或修改配置文件：`/etc/nginx/conf.d/vhr.conf`（Linux）或 `nginx/conf/nginx.conf`（Windows）

```nginx
upstream vhr_backend {
    server 127.0.0.1:8081;
    # 多实例负载均衡
    # server 127.0.0.1:8082;
    # server 127.0.0.1:8083;
}

server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名或 IP
    
    # 前端静态文件
    location / {
        root /opt/vhr/dist;       # 前端 dist 目录路径
        index index.html;
        try_files $uri $uri/ /index.html;  # 支持 Vue Router history 模式
    }
    
    # 后端 API 代理
    location /api/ {
        proxy_pass http://vhr_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket 支持
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # WebSocket 代理
    location /ws/ {
        proxy_pass http://vhr_backend/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # Gzip 压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    gzip_min_length 1024;
    
    # 静态资源缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
    }
}
```

### 8.3 HTTPS 配置（推荐）

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    # SSL 证书配置
    ssl_certificate /path/to/your/cert.pem;
    ssl_certificate_key /path/to/your/key.pem;
    
    # SSL 安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # 其他配置同上
    location / {
        root /opt/vhr/dist;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://vhr_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# HTTP 重定向到 HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### 8.4 重启 Nginx

```bash
# 测试配置文件
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx

# 或重新加载配置（不中断服务）
sudo systemctl reload nginx

# Windows 环境
nginx -t
nginx -s reload
```

---

## 9. FastDFS 部署（可选）

如果需要文件上传功能，需部署 FastDFS。

### 9.1 安装 FastDFS

详细安装步骤请参考 FastDFS 官方文档：https://github.com/happyfish100/fastdfs

### 9.2 修改配置

修改后端配置文件：

```yaml
fastdfs:
  nginx:
    host: http://your-fastdfs-host/  # FastDFS Nginx 访问地址
```

---

## 10. 完整部署流程

### 10.1 开发环境部署流程

```bash
# 1. 启动 MySQL（已安装并导入数据）
# 2. 启动 Redis
redis-server

# 3. 启动 RabbitMQ
rabbitmq-server

# 4. 启动后端
cd D:/Projects/dxyy/vhr/vhr/vhrserver
mvn clean package -DskipTests
java -jar vhr-web/target/vhr-web-1.0.jar

# 5. 启动前端
cd D:/Projects/dxyy/vhr/vuehr
npm install
npm run serve

# 6. 访问系统
# 前端：http://localhost:8080
# 后端：http://localhost:8081
```

### 10.2 生产环境部署流程

```bash
# 1. 确保所有依赖服务已启动
sudo systemctl status mysql
sudo systemctl status redis
sudo systemctl status rabbitmq-server

# 2. 构建后端
cd /opt/vhr/vhr/vhrserver
mvn clean package -DskipTests

# 3. 启动后端服务
sudo systemctl start vhr-web
sudo systemctl start mailserver  # 可选

# 4. 构建前端
cd /opt/vhr/vuehr
npm install
npm run build

# 5. 部署前端到 Nginx
sudo cp -r dist/* /usr/share/nginx/html/

# 6. 配置并启动 Nginx
sudo nginx -t
sudo systemctl restart nginx

# 7. 访问系统
# 浏览器打开：http://your-domain.com
```

---

## 11. 验证部署

### 11.1 检查服务状态

```bash
# 检查后端服务
curl http://localhost:8081

# 检查前端
curl http://localhost

# 检查数据库连接
mysql -u root -p -e "use vhr; show tables;"

# 检查 Redis 连接
redis-cli -a your_password ping

# 检查 RabbitMQ 连接
rabbitmqctl status
```

### 11.2 访问系统

打开浏览器访问：http://your-domain.com 或 http://localhost

**默认管理员账号：**

根据数据库初始化脚本，默认账号可能为：

- 用户名：admin
- 密码：123（具体请查看数据库 hr 表）

### 11.3 功能测试清单

- [ ] 用户登录
- [ ] 员工信息管理
- [ ] 部门管理
- [ ] 薪资管理
- [ ] 系统设置
- [ ] 在线聊天（WebSocket）
- [ ] 邮件发送（RabbitMQ + mailserver）
- [ ] 文件上传（FastDFS）
- [ ] Excel 导入导出

---

## 12. 常见问题

### 12.1 数据库连接失败

**问题：** `Communications link failure`

**解决方案：**

1. 检查 MySQL 服务是否启动
2. 检查数据库连接配置（用户名、密码、URL）
3. 检查防火墙是否开放 3306 端口
4. 检查 MySQL 是否允许远程连接

```sql
-- 允许远程连接
GRANT ALL PRIVILEGES ON vhr.* TO 'root'@'%' IDENTIFIED BY 'your_password';
FLUSH PRIVILEGES;
```

### 12.2 Redis 连接失败

**问题：** `Could not get a resource from the pool`

**解决方案：**

1. 检查 Redis 服务是否启动
2. 检查 Redis 配置（host、port、password）
3. 测试 Redis 连接：`redis-cli -h host -p port -a password ping`

### 12.3 RabbitMQ 连接失败

**问题：** `Failed to connect to RabbitMQ`

**解决方案：**

1. 检查 RabbitMQ 服务是否启动
2. 检查 RabbitMQ 用户权限
3. 访问管理界面检查：http://localhost:15672

```bash
# 创建用户并授权
rabbitmqctl add_user vhr_user password
rabbitmqctl set_user_tags vhr_user administrator
rabbitmqctl set_permissions -p / vhr_user ".*" ".*" ".*"
```

### 12.4 前端无法访问后端 API

**问题：** 跨域错误 `CORS`

**解决方案：**

1. 使用 Nginx 反向代理（推荐）
2. 或在后端添加 CORS 配置：

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("http://localhost:8080")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
```

### 12.5 WebSocket 连接失败

**问题：** 在线聊天无法连接

**解决方案：**

1. 检查 Nginx WebSocket 代理配置
2. 检查前端 WebSocket 连接地址
3. 检查后端 WebSocket 配置

---

## 13. 性能优化建议

### 13.1 数据库优化

```sql
-- 创建索引
CREATE INDEX idx_employee_name ON employee(name);
CREATE INDEX idx_employee_department ON employee(department_id);

-- 配置文件优化（my.cnf）
[mysqld]
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
max_connections = 1000
```

### 13.2 Redis 优化

```conf
# redis.conf
maxmemory 2gb
maxmemory-policy allkeys-lru
```

### 13.3 JVM 优化

```bash
# 启动参数
java -Xms1g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar vhr-web.jar
```

### 13.4 Nginx 优化

```nginx
# nginx.conf
worker_processes auto;
worker_connections 1024;

http {
    keepalive_timeout 65;
    client_max_body_size 10m;
}
```

---

## 14. 安全建议

1. **修改默认密码**：修改数据库、Redis、RabbitMQ 默认密码
2. **使用 HTTPS**：生产环境强制使用 HTTPS
3. **防火墙配置**：只开放必要端口（80, 443, 3306）
4. **定期备份**：配置数据库定时备份
5. **日志监控**：配置应用日志监控和告警
6. **安全扫描**：定期进行安全漏洞扫描

---

## 15. 附录

### 15.1 目录结构

```
/opt/vhr/
├── vhr/                    # 源代码
│   ├── vhr/               # 后端代码
│   │   ├── vhrserver/
│   │   └── mailserver/
│   └── vuehr/             # 前端代码
├── dist/                   # 前端构建产物
├── logs/                   # 日志目录
│   ├── vhr-web.log
│   └── mailserver.log
└── backups/               # 备份目录
```

### 15.2 常用命令

```bash
# 查看日志
tail -f /opt/vhr/logs/vhr-web.log

# 重启服务
sudo systemctl restart vhr-web

# 查看进程
ps aux | grep vhr

# 查看端口
netstat -an | grep 8081

# 数据库备份
mysqldump -u root -p vhr > backup_$(date +%Y%m%d).sql
```

### 15.3 技术支持

如遇到问题，请参考：

- 项目 GitHub：https://github.com/lenve/vhr
- Spring Boot 文档：https://spring.io/projects/spring-boot
- Vue.js 文档：https://vuejs.org/

---

*文档编写完成，祝部署顺利！*
