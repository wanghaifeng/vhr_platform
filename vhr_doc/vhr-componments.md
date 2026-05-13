# vhr Project Component Diagram

## 1. Overall System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                            User Browser                           │
│                       (Vue.js SPA Application)                   │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS/HTTP
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│                     Nginx (Reverse Proxy)                       │
│  ┌──────────────────┐         ┌──────────────────┐              │
│  │  Static Resource   │         │  API Request      │              │
│  │   Service         │         │   Forwarding     │              │
│  │ (Vue Build Files)  │         │                  │              │
│  └──────────────────┘         └────────┬─────────┘              │
└─────────────────────────────────────────┼───────────────────────┘
                                          │
                                          ↓
┌─────────────────────────────────────────────────────────────────┐
│                  Spring Boot Microservice Cluster               │
│  ┌───────────────────────────┐  ┌──────────────────────────┐   │
│  │     vhr-web (Main Service)  │  │   mailserver (Email Service)  │   │
│  │      Port: 8081             │  │      Port: 8082          │   │
│  └─────────────┬─────────────┘  └───────────┬──────────────┘   │
└────────────────┼─────────────────────────────┼──────────────────┘
                 │                             │
       ┌─────────┴──────────┐                  │
       │                    │                  │
       ↓                    ↓                  ↓
┌─────────────┐      ┌─────────────┐   ┌─────────────┐
│   Redis     │      │  RabbitMQ   │   │   MySQL     │
│  (Cache)    │      │ (Message Queue) │   │  (Database)   │
│  Port:6379  │      │  Port:5672  │   │  Port:3306  │
└─────────────┘      └─────────────┘   └─────────────┘
```

---

## 2. Frontend Component Structure Diagram

### 2.1 Frontend Technology Stack Components

```
┌─────────────────────────────────────────────────────────┐
│                    Vue.js Frontend Application          │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Vue.js    │  │ Vue Router  │  │    Vuex     │    │
│  │   2.6.10    │  │   3.0.3     │  │   3.1.1     │    │
│  │  (Core Framework) │  │  (Routing Management) │  │  (State Management) │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ Element UI  │  │   Axios     │  │ Font Awesome│    │
│  │   2.12.0    │  │   0.19.0    │  │    4.7.0    │    │
│  │ (UI Component Library) │  │ (HTTP Requests) │  │  (Icon Library)   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐                     │
│  │   SockJS    │  │    STOMP    │                     │
│  │ (WebSocket) │  │  (Protocol) │                     │
│  └─────────────┘  └─────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Frontend Page Component Hierarchy

```
App.vue (Root Component)
    │
    ├── Login.vue (Login Page)
    │
    └── Home.vue (Main Page Framework)
            │
            ├── Top Navigation Bar
            │
            ├── Left Sidebar Menu
            │
            └── Content Area
                    │
                    ├── Employee Management Module (emp/)
                    │   ├── EmpBasic.vue (Basic Info)
                    │   └── EmpAdv.vue (Advanced Info)
                    │
                    ├── Personal Affairs Module (per/)
                    │   ├── PerEmp.vue (My Info)
                    │   ├── PerEc.vue (Employee Rewards/Punishments)
                    │   ├── PerMv.vue (Employee Transfer)
                    │   ├── PerSalary.vue (Salary Account Set)
                    │   └── PerTrain.vue (Employee Training)
                    │
                    ├── Salary Management Module (sal/)
                    │   ├── SalSob.vue (Salary Account Set Management)
                    │   ├── SalSobCfg.vue (Account Set Settings)
                    │   ├── SalMonth.vue (Monthly Salary)
                    │   ├── SalTable.vue (Salary Table)
                    │   └── SalSearch.vue (Salary Query)
                    │
                    ├── Statistics Analysis Module (sta/)
                    │   ├── StaAll.vue (Comprehensive Info)
                    │   ├── StaPers.vue (Employee Info)
                    │   ├── StaRecord.vue (HR Records)
                    │   └── StaScore.vue (Attendance Info)
                    │
                    ├── System Management Module (sys/)
                    │   ├── SysBasic.vue (Basic Info Settings)
                    │   ├── SysHr.vue (User Management)
                    │   ├── SysCfg.vue (System Config)
                    │   ├── SysData.vue (Data Backup)
                    │   ├── SysInit.vue (Initialization)
                    │   └── SysLog.vue (Operation Log)
                    │
                    └── Online Chat Module (chat/)
                        └── FriendChat.vue
```

---

## 3. Backend Component Structure Diagram

### 3.1 Backend Technology Stack Components

```
┌─────────────────────────────────────────────────────────┐
│                 Spring Boot Backend Application         │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │Spring Boot  │  │   Spring    │  │   MyBatis   │    │
│  │   2.4.0     │  │  Security   │  │   2.1.0     │    │
│  │ (Core Framework) │  │ (Security Framework) │  │ (ORM Framework) │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Druid     │  │  FastDFS    │  │    POI      │    │
│  │   1.1.10    │  │  1.27.0.0   │  │   4.1.1     │    │
│  │ (Connection Pool) │  │ (File Storage) │  │(Excel Processing) │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐                     │
│  │ WebSocket   │  │  Thymeleaf  │                     │
│  │ (Real-time Communication) │  │ (Template Engine) │                     │
│  └─────────────┘  └─────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

### 3.2 Backend Module Hierarchy

```
vhr (Parent Project)
    │
    ├── vhrserver (Main Service Module)
    │       │
    │       ├── vhr-web (Web Control Layer) - Port: 8081
    │       │       ├── controller/ (Controllers)
    │       │       │   ├── LoginController (Login Control)
    │       │       │   ├── HrInfoController (HR Info)
    │       │       │   ├── ChatController (Chat Control)
    │       │       │   ├── WsController (WebSocket)
    │       │       │   ├── emp/ (Employee Management API)
    │       │       │   ├── salary/ (Salary Management API)
    │       │       │   ├── system/ (System Management API)
    │       │       │   └── config/ (Config API)
    │       │       │
    │       │       └── config/ (Configuration Classes)
    │       │               ├── SecurityConfig (Security Config)
    │       │               ├── RedisConfig (Redis Config)
    │       │               ├── RabbitMQConfig (Message Queue Config)
    │       │               └── WebSocketConfig (WebSocket Config)
    │       │
    │       ├── vhr-service (Business Logic Layer)
    │       │       ├── EmployeeService (Employee Service)
    │       │       ├── DepartmentService (Department Service)
    │       │       ├── HrService (HR User Service)
    │       │       ├── MenuService (Menu Service)
    │       │       ├── SalaryService (Salary Service)
    │       │       ├── PositionService (Position Service)
    │       │       └── JobLevelService (Job Level Service)
    │       │
    │       ├── vhr-mapper (Data Access Layer)
    │       │       ├── EmployeeMapper
    │       │       ├── DepartmentMapper
    │       │       ├── HrMapper
    │       │       ├── MenuMapper
    │       │       └── SalaryMapper
    │       │
    │       └── vhr-model (Entity Model Layer)
    │               ├── Employee (Employee)
    │               ├── Department (Department)
    │               ├── Position (Position)
    │               ├── JobLevel (Job Level)
    │               ├── Salary (Salary Account Set)
    │               ├── AdjustSalary (Salary Adjustment Record)
    │               ├── Appraise (Appraisal Record)
    │               ├── Hr (HR User)
    │               ├── Menu (Menu)
    │               └── Role (Role)
    │
    └── mailserver (Email Service Module) - Port: 8082
            ├── MailserverApplication (Startup Class)
            ├── MailReceiver (Message Listener)
            └── resources/
                    └── mail.html (Email Template)
```

### 3.3 Module Dependency Relationship

```
vhr-web (Web Layer)
    │
    └──→ vhr-service (Service Layer)
              │
              └──→ vhr-mapper (Mapper Layer)
                        │
                        └──→ vhr-model (Model Layer)
```

---

## 4. Middleware Component Diagram

```
┌─────────────────────────────────────────────────────────┐
│                       Middleware Layer                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌───────────────────────────────────────────────┐    │
│  │              MySQL Database                    │    │
│  │  ├─ employee (Employee Info Table)            │    │
│  │  ├─ department (Department Table)             │    │
│  │  ├─ position (Position Table)                 │    │
│  │  ├─ joblevel (Job Level Table)                │    │
│  │  ├─ salary (Salary Account Set Table)         │    │
│  │  ├─ adjustsalary (Salary Adjustment Record Table) │    │
│  │  ├─ appraise (Appraisal Record Table)         │    │
│  │  ├─ hr (HR User Table)                        │    │
│  │  ├─ role (Role Table)                         │    │
│  │  ├─ menu (Menu Table)                         │    │
│  │  ├─ menu_role (Menu Role Association Table)   │    │
│  │  └─ mail_send_log (Email Send Log Table)      │    │
│  └───────────────────────────────────────────────┘    │
│                                                         │
│  ┌─────────────────────┐  ┌─────────────────────┐    │
│  │      Redis          │  │     RabbitMQ        │    │
│  │  ├─ Session Storage   │  │  ├─ Email Queue      │    │
│  │  ├─ Menu Cache        │  │  └─ Message Listener   │    │
│  │  └─ Data Cache       │  │                     │    │
│  └─────────────────────┘  └─────────────────────┘    │
│                                                         │
│  ┌───────────────────────────────────────────────┐    │
│  │              FastDFS (File Storage)             │    │
│  │  ├─ Employee Avatar Storage                   │    │
│  │  └─ Document Attachment Storage                │    │
│  └───────────────────────────────────────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 5. Data Flow Component Diagram

### 5.1 Request Processing Flow

```
User Request
    │
    ↓
Vue.js Frontend
    │ (Axios HTTP Request)
    ↓
Nginx Reverse Proxy
    │ (Request Forwarding)
    ↓
Spring Security Filter Chain
    │ (Authentication/Authorization)
    ↓
Controller
    │ (Request Processing)
    ↓
Service Business Layer
    │ (Business Logic)
    ↓
Mapper Data Access Layer
    │ (MyBatis SQL)
    ↓
MySQL Database
    │ (Return Result)
    ↓
Service Business Layer
    │ (Data Processing)
    ↓
Controller
    │ (Response Encapsulation)
    ↓
Frontend View Rendering
```

### 5.2 Email Sending Flow

```
Employee Onboarding Operation
    │
    ↓
EmployeeService
    │ (Save Employee Info)
    ↓
RabbitMQ Message Queue
    │ (Asynchronous Message)
    ↓
mailserver Email Service
    │ (Message Listener)
    ↓
Thymeleaf Template Rendering
    │ (Generate Email Content)
    ↓
SMTP Email Server
    │ (Send Email)
    ↓
Employee Inbox
```

### 5.3 WebSocket Communication Flow

```
User Login
    │
    ↓
Establish WebSocket Connection
    │ (SockJS + STOMP)
    ↓
WsController Handle Connection
    │ (Session Management)
    ↓
Redis Store Online Status
    │
    ↓
Chat Message Broadcast
    │ (Message Distribution)
    ↓
Online Users Receive Messages
```

---

## 6. Security Component Diagram

```
┌─────────────────────────────────────────────────────────┐
│                     Security Architecture               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌───────────────────────────────────────────────┐    │
│  │           Spring Security Filter Chain          │    │
│  │  ├─ AuthenticationFilter                     │    │
│  │  ├─ AuthorizationFilter                     │    │
│  │  ├─ CORS Filter (Cross-Origin Handling)     │    │
│  │  └─ CSRF Filter (Cross-Site Request Forgery Protection) │    │
│  └───────────────────────────────────────────────┘    │
│                         │                              │
│                         ↓                              │
│  ┌───────────────────────────────────────────────┐    │
│  │              Authentication Methods             │    │
│  │  ├─ Username/Password Login                   │    │
│  │  ├─ Remember-Me                               │    │
│  │  └─ Session Management (Redis Storage)        │    │
│  └───────────────────────────────────────────────┘    │
│                         │                              │
│                         ↓                              │
│  ┌───────────────────────────────────────────────┐    │
│  │              Authorization Model              │    │
│  │  ├─ RBAC (Role-Based Access Control)          │    │
│  │  ├─ Users (Hr)                                │    │
│  │  ├─ Roles (Role)                              │    │
│  │  └─ Menu Permissions (Menu)                   │    │
│  └───────────────────────────────────────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 7. Component List Table

### 7.1 Frontend Components

| Component Name | Technology Stack | Version | Function Description |
|----------------|------------------|---------|----------------------|
| Vue.js         | JavaScript Framework | 2.6.10  | Frontend core framework      |
| Vue Router     | Routing Management | 3.0.3   | SPA routing                  |
| Vuex           | State Management | 3.1.1   | Global state management      |
| Element UI     | UI Component Library | 2.12.0  | UI components                |
| Axios          | HTTP Client      | 0.19.0  | HTTP request handling        |
| SockJS         | WebSocket        | -       | Real-time communication client |
| Font Awesome   | Icon Library     | 4.7.0   | Icon resources               |

### 7.2 Backend Components

| Component Name | Technology Stack | Version | Function Description |
|----------------|------------------|---------|----------------------|
| Spring Boot    | Java Framework   | 2.4.0   | Backend core framework       |
| Spring Security| Security Framework | -       | Authentication and Authorization |
| MyBatis        | ORM Framework    | 2.1.0   | Data persistence             |
| Druid          | Connection Pool  | 1.1.10  | Database connection management |
| Redis          | Cache            | -       | Cache and Session storage    |
| RabbitMQ       | Message Queue    | -       | Asynchronous message processing |
| FastDFS        | File Storage     | 1.27.0.0| Distributed file storage     |
| WebSocket      | Real-time Communication | -       | Online chat                  |
| POI            | Excel Processing | 4.1.1   | Excel import/export          |

### 7.3 Database Components

| Table Name      | Function Description       | Main Fields                 |
|-----------------|----------------------------|-----------------------------|
| employee        | Employee Information       | id, name, gender, birthday, phone, address... |
| department      | Department Information     | id, deptName, parentId      |
| position        | Position Information       | id, posName                 |
| joblevel        | Job Level Information      | id, jobLevelName            |
| salary          | Salary Account Set         | id, basicSalary, bonus, lunchSalary... |
| hr              | HR User                    | id, name, phone, username, password |
| role            | Role                       | id, name, nameZh            |
| menu            | Menu                       | id, url, path, component, name... |

---

## 8. Component Interaction Summary

```
┌──────────────────────────────────────────────────────────┐
│                      vhr System Component Interaction Diagram         │
└──────────────────────────────────────────────────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
    Frontend Components Backend Components Middleware Components
         │                 │                 │
         │                 │                 │
    ┌────┴────┐       ┌────┴────┐       ┌────┴────┐
    │ Vue.js  │       │ Spring  │       │  MySQL  │
    │  SPA    │←HTTP─→│  Boot   │←SQL──→│ Database│
    └─────────┘       └────┬────┘       └─────────┘
                          │
                   ┌──────┼──────┐
                   │      │      │
              ┌────┴┐ ┌──┴───┐ ┌┴─────┐
              │Redis│ │RabbitMQ│ │FastDFS│
              └─────┘ └───────┘ └──────┘
```

**Key Interaction Points:**

1. **Frontend ↔ Backend**: HTTP/HTTPS requests sent via Axios, received and processed by Spring Boot.
2. **Backend ↔ Database**: SQL operations via MyBatis, connection pool managed by Druid.
3. **Backend ↔ Redis**: Caches menu data, stores sessions, and online user status.
4. **Backend ↔ RabbitMQ**: Asynchronously sends email messages, decouples business logic.
5. **Backend ↔ FastDFS**: Stores employee avatars and document attachments.
6. **Frontend ↔ WebSocket**: Enables online chat functionality.
7. **Security Interaction**: Spring Security intercepts all requests for authentication and authorization checks.

---

*Document Generation Time: 2026-05-11*