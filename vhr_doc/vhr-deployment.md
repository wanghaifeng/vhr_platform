# vhr Project Deployment Documentation

## Document Information

| Project Name | vhr (Micro HR Management System) |
|--------------|----------------------------------|
| Document Version | v1.0                             |
| Creation Date | 2026-05-11                       |
| Document Type | Deployment Documentation         |

---

## 1. Deployment Overview

### 1.1 System Architecture

vhr is a front-end and back-end separated enterprise HR management system, mainly including the following components:

- **Frontend**: Vue.js Single Page Application
- **Backend**: Spring Boot Microservices (vhr-web + mailserver)
- **Database**: MySQL 8.0+
- **Cache**: Redis
- **Message Queue**: RabbitMQ
- **File Storage**: FastDFS (Optional)
- **Reverse Proxy**: Nginx

### 1.2 Deployment Methods

This document supports the following deployment methods:

1. **Development Environment Deployment**: Suitable for local development and testing.
2. **Production Environment Deployment**: Suitable for production launch.
3. **Docker Containerized Deployment**: Suitable for cloud environment deployment (Optional).

---

## 2. Environment Requirements

### 2.1 Hardware Requirements

| Environment | CPU  | Memory | Disk   | Description        |
|-------------|------|--------|--------|--------------------|
| Development | 2 Cores+ | 4GB+   | 20GB+  | Local development machine |
| Test        | 4 Cores+ | 8GB+   | 50GB+  | Test server        |
| Production  | 8 Cores+ | 16GB+  | 100GB+ | Production server  |

### 2.2 Software Requirements

| Software Name | Version Requirement | Required | Description          |
|---------------|---------------------|----------|----------------------|
| JDK           | 1.8+                | Yes      | Java Runtime Environment |
| MySQL         | 8.0+                | Yes      | Relational Database    |
| Redis         | 5.0+                | Yes      | Cache Database         |
| RabbitMQ      | 3.8+                | Yes      | Message Queue          |
| Node.js       | 12.0+               | Yes      | Frontend build environment |
| Maven         | 3.6+                | Yes      | Java Build Tool        |
| Nginx         | 1.18+               | No       | Reverse proxy (recommended for production) |
| FastDFS       | 5.0+                | No       | File storage (optional) |

### 2.3 Port Requirements

| Service      | Default Port | Description        |
|--------------|--------------|--------------------|
| vhr-web      | 8081         | Main service port  |
| mailserver   | 8082         | Email service port |
| MySQL        | 3306         | Database port      |
| Redis        | 6379         | Cache port         |
| RabbitMQ     | 5672         | Message queue port |
| RabbitMQ Management | 15672        | RabbitMQ management interface |
| Nginx        | 80/443       | Reverse proxy port |

---

## 3. Database Deployment

### 3.1 Install MySQL

**Windows Environment:**

1. Download MySQL 8.0+ installer: https://dev.mysql.com/downloads/mysql/
2. Run the installer, select "Developer Default" installation type.
3. Set the root user password (Recommendation: use a strong password for production).
4. Complete the installation and start the MySQL service.

**Linux Environment:**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mysql-server

# CentOS/RHEL
sudo yum install mysql-server

# Start service
sudo systemctl start mysql
sudo systemctl enable mysql

# Security configuration
sudo mysql_secure_installation
```

### 3.2 Create Database

```sql
-- Log in to MySQL
mysql -u root -p

-- Create database
CREATE DATABASE vhr DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Create user (Optional, recommended for production)
CREATE USER 'vhr_user'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON vhr.* TO 'vhr_user'@'%';
FLUSH PRIVILEGES;
```

### 3.3 Import Database Script

```bash
# Import SQL file
mysql -u root -p vhr < D:/Projects/dxyy/vhr/vhr.sql

# Or use MySQL command line
mysql> use vhr;
mysql> source D:/Projects/dxyy/vhr/vhr.sql;
```

### 3.4 Verify Database

```sql
-- View table structure
USE vhr;
SHOW TABLES;

-- You should see the following tables
-- employee, department, position, joblevel, salary,
-- adjustsalary, appraise, hr, role, menu, menu_role,
-- mail_send_log, etc.
```

---

## 4. Redis Deployment

### 4.1 Install Redis

**Windows Environment:**

1. Download Redis for Windows: https://github.com/microsoftarchive/redis/releases
2. Extract to a specified directory (e.g., C:\Redis).
3. Modify `redis.windows.conf` configuration file:
   ```
   bind 127.0.0.1
   port 6379
   requirepass 123
   ```
4. Start Redis service:
   ```cmd
   redis-server.exe redis.windows.conf
   ```

**Linux Environment:**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install redis-server

# CentOS/RHEL
sudo yum install redis

# Modify configuration file
sudo vi /etc/redis/redis.conf
# Set: bind 127.0.0.1
# Set: requirepass your_password

# Start service
sudo systemctl start redis
sudo systemctl enable redis

# Test connection
redis-cli -a your_password ping
```

### 4.2 Verify Redis

```bash
# Connect to Redis
redis-cli -h 127.0.0.1 -p 6379 -a 123

# Test commands
127.0.0.1:6379> ping
PONG

127.0.0.1:6379> set test "hello"
OK

127.0.0.1:6379> get test
"hello"
```

---

## 5. RabbitMQ Deployment

### 5.1 Install RabbitMQ

**Windows Environment:**

1. Download and install Erlang: https://www.erlang.org/downloads
2. Download RabbitMQ installer: https://www.rabbitmq.com/download.html
3. Install RabbitMQ.
4. Enable management plugin:
   ```cmd
   rabbitmq-plugins enable rabbitmq_management
   ```
5. Access management interface: http://localhost:15672 (default account: guest/guest).

**Linux Environment:**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install rabbitmq-server

# CentOS/RHEL
sudo yum install rabbitmq-server

# Start service
sudo systemctl start rabbitmq-server
sudo systemctl enable rabbitmq-server

# Enable management plugin
sudo rabbitmq-plugins enable rabbitmq_management

# Add user (Optional)
sudo rabbitmqctl add_user vhr_user your_password
sudo rabbitmqctl set_user_tags vhr_user administrator
sudo rabbitmqctl set_permissions -p / vhr_user ".*" ".*" ".*"
```

### 5.2 Verify RabbitMQ

```bash
# Check status
sudo rabbitmqctl status

# View user list
sudo rabbitmqctl list_users

# Access management interface
# Open in browser: http://localhost:15672
# Username: guest, Password: guest
```

---

## 6. Backend Deployment

### 6.1 Modify Configuration File

Configuration file location: `D:/Projects/dxyy/vhr/vhr/vhrserver/vhr-web/src/main/resources/application.yml`

**Main Configuration Items:**

```yaml
spring:
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    username: root                    # MySQL Username
    password: 123                     # MySQL Password
    url: jdbc:mysql://localhost:3306/vhr?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
    
  rabbitmq:
    username: guest                   # RabbitMQ Username
    password: guest                   # RabbitMQ Password
    host: 127.0.0.1                   # RabbitMQ Host Address
    publisher-confirms: true
    publisher-returns: true
    
  redis:
    host: 127.0.0.1                   # Redis Host Address
    database: 0
    port: 6379                        # Redis Port
    password: 123                     # Redis Password
    
  cache:
    cache-names: menus_cache
    
server:
  port: 8081                          # Service Port
  compression:
    enabled: true
    
fastdfs:
  nginx:
    host: http://192.168.91.128/     # FastDFS Address (Optional)
```

**Production Environment Configuration Suggestions:**

```yaml
spring:
  datasource:
    username: vhr_user               # Use dedicated database user
    password: strong_password_here   # Use strong password
    url: jdbc:mysql://your-db-host:3306/vhr?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=true
    
  rabbitmq:
    username: vhr_user               # Use dedicated RabbitMQ user
    password: strong_password_here
    host: your-rabbitmq-host
    
  redis:
    host: your-redis-host
    password: strong_password_here
```

### 6.2 Build Project

**Method One: Using Maven Command**

```bash
# Enter backend project directory
cd D:/Projects/dxyy/vhr/vhr/vhrserver

# Clean and package (skip tests)
mvn clean package -DskipTests

# Generated JAR package location:
# vhr-web/target/vhr-web-xxx.jar
```

**Method Two: Using IDE**

1. Open project with IntelliJ IDEA or Eclipse.
2. Right-click project → Run As → Maven build.
3. Enter Goals: `clean package -DskipTests`.
4. Click Run.

### 6.3 Start Main Service

**Development Environment:**

```bash
# Method One: Directly run JAR package
cd D:/Projects/dxyy/vhr/vhr/vhrserver/vhr-web/target
java -jar vhr-web-1.0.jar

# Method Two: Specify configuration file
java -jar vhr-web-1.0.jar --spring.config.location=application.yml

# Method Three: Run in background (Linux)
nohup java -jar vhr-web-1.0.jar > vhr.log 2>&1 &
```

**Production Environment (systemd recommended):**

Create service file `/etc/systemd/system/vhr-web.service`:

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

Start service:

```bash
sudo systemctl daemon-reload
sudo systemctl start vhr-web
sudo systemctl enable vhr-web
sudo systemctl status vhr-web
```

### 6.4 Deploy Email Service (Optional)

**Modify Configuration File:**

Location: `D:/Projects/dxyy/vhr/vhr/mailserver/src/main/resources/application.properties`

```properties
# Email server configuration
spring.mail.host=smtp.your-email-provider.com
spring.mail.port=587
spring.mail.username=your-email@example.com
spring.mail.password=your-email-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# RabbitMQ configuration
spring.rabbitmq.host=127.0.0.1
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest

# Service port
server.port=8082
```

**Build and Start:**

```bash
cd D:/Projects/dxyy/vhr/vhr/mailserver
mvn clean package -DskipTests
java -jar target/mailserver-1.0.jar
```

### 6.5 Verify Backend Service

```bash
# Check if service is started
curl http://localhost:8081

# View logs
tail -f vhr.log

# Check port usage
netstat -an | grep 8081
```

---

## 7. Frontend Deployment

### 7.1 Install Dependencies

```bash
# Enter frontend project directory
cd D:/Projects/dxyy/vhr/vuehr

# Install Node.js dependencies
npm install

# Or use domestic mirror for faster installation
npm install --registry=https://registry.npmmirror.com
```

### 7.2 Modify Backend API Address

Modify file: `D:/Projects/dxyy/vhr/vuehr/src/utils/api.js`

```javascript
// Development environment
let base = 'http://localhost:8081';

// Production environment
let base = 'http://your-server-ip:8081';
// Or use Nginx proxy
let base = '/api';
```

### 7.3 Development Environment Run

```bash
# Start development server
npm run serve

# Default access address: http://localhost:8080
```

### 7.4 Production Environment Build

```bash
# Build production version
npm run build

# Generated files are in dist/ directory
```

Generated directory structure:

```
dist/
├── index.html           # Entry HTML
├── css/                 # CSS files
│   ├── app.xxx.css
│   └── chunk-xxx.css
├── js/                  # JavaScript files
│   ├── app.xxx.js
│   ├── chunk-xxx.js
│   └── ...
└── img/                 # Image resources
```

### 7.5 Deploy Frontend Static Files

**Method One: Using Nginx (Recommended)**

See Section 8 Nginx Configuration for details.

**Method Two: Using Backend Static Resources**

Copy `dist/` directory contents to backend static resource directory:

```bash
# Spring Boot default static resource directory
cp -r dist/* D:/Projects/dxyy/vhr/vhr/vhrserver/vhr-web/src/main/resources/static/
```

**Method Three: Using Independent Static Server**

```bash
# Use serve tool
npm install -g serve
serve -s dist -p 80

# Use http-server tool
npm install -g http-server
http-server dist -p 80
```

---

## 8. Nginx Configuration (Recommended for Production)

### 8.1 Install Nginx

**Windows Environment:**

1. Download Nginx: http://nginx.org/en/download.html
2. Extract to a specified directory (e.g., C:\nginx).
3. Start Nginx:
   ```cmd
   cd C:\nginx
   start nginx
   ```

**Linux Environment:**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx

# Start service
sudo systemctl start nginx
sudo systemctl enable nginx
```

### 8.2 Configure Nginx

Create or modify configuration file: `/etc/nginx/conf.d/vhr.conf` (Linux) or `nginx/conf/nginx.conf` (Windows)

```nginx
upstream vhr_backend {
    server 127.0.0.1:8081;
    # Multi-instance load balancing
    # server 127.0.0.1:8082;
    # server 127.0.0.1:8083;
}

server {
    listen 80;
    server_name your-domain.com;  # Replace with your domain or IP
    
    # Frontend static files
    location / {
        root /opt/vhr/dist;       # Frontend dist directory path
        index index.html;
        try_files $uri $uri/ /index.html;  # Support Vue Router history mode
    }
    
    # Backend API proxy
    location /api/ {
        proxy_pass http://vhr_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # WebSocket proxy
    location /ws/ {
        proxy_pass http://vhr_backend/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    gzip_min_length 1024;
    
    # Static resource caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
    }
}
```

### 8.3 HTTPS Configuration (Recommended)

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    # SSL certificate configuration
    ssl_certificate /path/to/your/cert.pem;
    ssl_certificate_key /path/to/your/key.pem;
    
    # SSL security configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Other configurations as above
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

# HTTP redirect to HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### 8.4 Restart Nginx

```bash
# Test configuration file
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Or reload configuration (without interrupting service)
sudo systemctl reload nginx

# Windows Environment
nginx -t
nginx -s reload
```

---

## 9. FastDFS Deployment (Optional)

If file upload functionality is required, FastDFS needs to be deployed.

### 9.1 Install FastDFS

Refer to the official FastDFS documentation for detailed installation steps: https://github.com/happyfish100/fastdfs

### 9.2 Modify Configuration

Modify backend configuration file:

```yaml
fastdfs:
  nginx:
    host: http://your-fastdfs-host/  # FastDFS Nginx access address
```

---

## 10. Complete Deployment Process

### 10.1 Development Environment Deployment Process

```bash
# 1. Start MySQL (already installed and data imported)
# 2. Start Redis
redis-server

# 3. Start RabbitMQ
rabbitmq-server

# 4. Start Backend
cd D:/Projects/dxyy/vhr/vhr/vhrserver
mvn clean package -DskipTests
java -jar vhr-web/target/vhr-web-1.0.jar

# 5. Start Frontend
cd D:/Projects/dxyy/vhr/vuehr
npm install
npm run serve

# 6. Access System
# Frontend: http://localhost:8080
# Backend: http://localhost:8081
```

### 10.2 Production Environment Deployment Process

```bash
# 1. Ensure all dependent services are started
sudo systemctl status mysql
sudo systemctl status redis
sudo systemctl status rabbitmq-server

# 2. Build Backend
cd /opt/vhr/vhr/vhrserver
mvn clean package -DskipTests

# 3. Start Backend Service
sudo systemctl start vhr-web
sudo systemctl start mailserver  # Optional

# 4. Build Frontend
cd /opt/vhr/vuehr
npm install
npm run build

# 5. Deploy Frontend to Nginx
sudo cp -r dist/* /usr/share/nginx/html/

# 6. Configure and Start Nginx
sudo nginx -t
sudo systemctl restart nginx

# 7. Access System
# Open in browser: http://your-domain.com
```

---

## 11. Verify Deployment

### 11.1 Check Service Status

```bash
# Check backend service
curl http://localhost:8081

# Check frontend
curl http://localhost

# Check database connection
mysql -u root -p -e "use vhr; show tables;"

# Check Redis connection
redis-cli -a your_password ping

# Check RabbitMQ connection
rabbitmqctl status
```

### 11.2 Access System

Open browser and access: http://your-domain.com or http://localhost

**Default Administrator Account:**

According to the database initialization script, the default account may be:

- Username: admin
- Password: 123 (Please check the `hr` table in the database for specifics)

### 11.3 Feature Test Checklist

- [ ] User login
- [ ] Employee information management
- [ ] Department management
- [ ] Salary management
- [ ] System settings
- [ ] Online chat (WebSocket)
- [ ] Email sending (RabbitMQ + mailserver)
- [ ] File upload (FastDFS)
- [ ] Excel import/export

---

## 12. Common Problems

### 12.1 Database Connection Failure

**Problem:** `Communications link failure`

**Solution:**

1. Check if MySQL service is running.
2. Check database connection configuration (username, password, URL).
3. Check if firewall has port 3306 open.
4. Check if MySQL allows remote connections.

```sql
-- Allow remote connections
GRANT ALL PRIVILEGES ON vhr.* TO 'root'@'%' IDENTIFIED BY 'your_password';
FLUSH PRIVILEGES;
```

### 12.2 Redis Connection Failure

**Problem:** `Could not get a resource from the pool`

**Solution:**

1. Check if Redis service is running.
2. Check Redis configuration (host, port, password).
3. Test Redis connection: `redis-cli -h host -p port -a password ping`.

### 12.3 RabbitMQ Connection Failure

**Problem:** `Failed to connect to RabbitMQ`

**Solution:**

1. Check if RabbitMQ service is running.
2. Check RabbitMQ user permissions.
3. Access management interface: http://localhost:15672.

```bash
# Create user and grant permissions
rabbitmqctl add_user vhr_user password
rabbitmqctl set_user_tags vhr_user administrator
rabbitmqctl set_permissions -p / vhr_user ".*" ".*" ".*"
```

### 12.4 Frontend Cannot Access Backend API

**Problem:** Cross-origin error `CORS`

**Solution:**

1. Use Nginx as a reverse proxy (recommended).
2. Or add CORS configuration in the backend:

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

### 12.5 WebSocket Connection Failure

**Problem:** Online chat cannot connect.

**Solution:**

1. Check Nginx WebSocket proxy configuration.
2. Check frontend WebSocket connection address.
3. Check backend WebSocket configuration.

---

## 13. Performance Optimization Suggestions

### 13.1 Database Optimization

```sql
-- Create index
CREATE INDEX idx_employee_name ON employee(name);
CREATE INDEX idx_employee_department ON employee(department_id);

-- Configuration file optimization (my.cnf)
[mysqld]
innodb_buffer_pool_size = 1G
innodb_log_file_size = 256M
max_connections = 1000
```

### 13.2 Redis Optimization

```conf
# redis.conf
maxmemory 2gb
maxmemory-policy allkeys-lru
```

### 13.3 JVM Optimization

```bash
# Startup parameters
java -Xms1g -Xmx2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -jar vhr-web.jar
```

### 13.4 Nginx Optimization

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

## 14. Security Recommendations

1. **Change Default Passwords**: Modify default passwords for MySQL, Redis, RabbitMQ.
2. **Use HTTPS**: Enforce HTTPS in production environments.
3. **Firewall Configuration**: Only open necessary ports (80, 443, 3306).
4. **Regular Backups**: Configure scheduled database backups.
5. **Log Monitoring**: Configure application log monitoring and alerts.
6. **Security Scanning**: Conduct regular security vulnerability scans.

---

## 15. Appendix

### 15.1 Directory Structure

```
/opt/vhr/
├── vhr/                    # Source code
│   ├── vhr/               # Backend code
│   │   ├── vhrserver/
│   │   └── mailserver/
│   └── vuehr/             # Frontend code
├── dist/                   # Frontend build artifacts
├── logs/                   # Log directory
│   ├── vhr-web.log
│   └── mailserver.log
└── backups/               # Backup directory
```

### 15.2 Common Commands

```bash
# View logs
tail -f /opt/vhr/logs/vhr-web.log

# Restart service
sudo systemctl restart vhr-web

# View processes
ps aux | grep vhr

# View ports
netstat -an | grep 8081

# Database backup
mysqldump -u root -p vhr > backup_$(date +%Y%m%d).sql
```

### 15.3 Technical Support

For issues, please refer to:

- Project GitHub: https://github.com/lenve/vhr
- Spring Boot Documentation: https://spring.io/projects/spring-boot
- Vue.js Documentation: https://vuejs.org/

---

*Document written, happy deployment!*