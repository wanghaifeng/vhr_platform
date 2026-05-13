# vhr Project Infrastructure Diagram

<img src="./infra_diagram.png">


```mermaid
---
config:
  layout: dagre
---
flowchart LR
 subgraph subGraph0["User Layer"]
        B("CDN/Load Balancer")
        A["User Browser/Client"]
  end
 subgraph subGraph1["Network Layer"]
        C{"Web Application Firewall/API Gateway"}
        D["Nginx Reverse Proxy/API Gateway"]
  end
 subgraph subGraph2["Application Layer (vhr-web & mailserver)"]
    direction LR
        E("Spring Boot Application Cluster")
        F{"Cache: Redis"}
        G{"Message Queue: RabbitMQ"}
        H{"File Storage: FastDFS/OSS"}
  end
 subgraph subGraph3["Data Layer"]
        I["Database: MySQL/RDS"]
  end
 subgraph subGraph4["Monitoring & Logging"]
        J["Logging Service: ELK/SLS"]
        K["Monitoring Service: Prometheus/Grafana/ARMS"]
  end
 subgraph subGraph5["Security & Compliance"]
        M("CI/CD Pipeline")
        L["Policy as Code: OPA/Harness Policy"]
  end
 subgraph subGraph6["CI/CD (GitHub Actions & Harness)"]
        N("Code Repository: Git")
        O("GitHub Actions CI")
        P("Harness CD")
  end
    A -- HTTPS/HTTP --> B
    B --> C
    C --> D
    D --> E
    E --> F & G & H & I & J & K
    L --> M
    M --> N
    N --> O
    O --> P
    P --> E & I & F & G & H

     B:::boundary
     A:::actor
     C:::boundary
     D:::boundary
     E:::system
     F:::service
     G:::service
     H:::service
     I:::database
     J:::tool
     K:::tool
     M:::tool
     L:::tool
     N:::tool
     O:::tool
     P:::tool
    classDef default fill:#fff,stroke:#333,stroke-width:2px,color:#000
    classDef actor fill:#ADD8E6,stroke:#336699,stroke-width:2px,color:#000
    classDef boundary fill:#F0FFF0,stroke:#3CB371,stroke-width:2px,color:#000
    classDef system fill:#F8F8FF,stroke:#6A5ACD,stroke-width:2px,color:#000
    classDef database fill:#FFE4B5,stroke:#FF8C00,stroke-width:2px,color:#000
    classDef service fill:#E6E6FA,stroke:#8A2BE2,stroke-width:2px,color:#000
    classDef tool fill:#F5DEB3,stroke:#DAA520,stroke-width:2px,color:#000