## VPC Diagram

```mermaid
flowchart LR
  %% External
  Internet((Internet))
  R53[Route 53 / DNS]:::ext

  %% VPC
  subgraph VPC[ VPC 172.20.0.0/16 ]
    direction LR

    %% AZ-a
    subgraph AZa[AZ-a]
      direction TB
      PUBa[(Public Subnet\nALB ENI)]:::pub
      FWa[(Firewall Subnet)]:::fw
      APPa[(Private App Subnet\nTargets: EC2/ECS/PODs)]:::app
      DATAa[(Private Data Subnet)]:::data
    end

    %% AZ-b
    subgraph AZb[AZ-b]
      direction TB
      PUBb[(Public Subnet\nALB ENI)]:::pub
      FWb[(Firewall Subnet)]:::fw
      APPb[(Private App Subnet\nTargets)]:::app
      DATAb[(Private Data Subnet)]:::data
    end

    %% AZ-c
    subgraph AZc[AZ-c]
      direction TB
      PUBc[(Public Subnet\nALB ENI)]:::pub
      FWc[(Firewall Subnet)]:::fw
      APPc[(Private App Subnet\nTargets)]:::app
      DATAc[(Private Data Subnet)]:::data
    end

    %% Shared infra
    ALB[(Application Load Balancer\nMulti-AZ)]:::lb
    NFW[(AWS Network Firewall\nEndpoint per AZ)]:::nfw
    NAT[(NAT GW per AZ)]:::nat
    IGW[(Internet Gateway)]:::igw
    S3EP[(S3 VPC Endpoint - Gateway\nAssociated to App RTs)]:::s3
  end

  %% DNS → ALB
  Internet --> R53 --> ALB
  %% ALB ENI in Public subnets
  ALB --- PUBa
  ALB --- PUBb
  ALB --- PUBc

  %% Ingress: ALB -> Targets in App subnets (SG 허용)
  ALB -->|HTTP/HTTPS\n(Target Group)| APPa
  ALB -->|HTTP/HTTPS\n(Target Group)| APPb
  ALB -->|HTTP/HTTPS\n(Target Group)| APPc

  %% Health check도 동일 경로
  ALB -. Health checks .-> APPa
  ALB -. Health checks .-> APPb
  ALB -. Health checks .-> APPc

  %% Default egress from App/Data
  APPa -- "0.0.0.0/0 (default)" --> NFW
  APPb -- "0.0.0.0/0 (default)" --> NFW
  APPc -- "0.0.0.0/0 (default)" --> NFW
  NFW --> NAT --> IGW

  %% S3 전용 경로(자동 경로, Gateway EP)
  APPa -- "S3 Prefix (via App RT)" --> S3EP
  APPb -- "S3 Prefix (via App RT)" --> S3EP
  APPc -- "S3 Prefix (via App RT)" --> S3EP

  classDef ext fill:#f6f6ff,stroke:#6270f0,stroke-width:1.2;
  classDef pub fill:#eefaff,stroke:#3aa0d8;
  classDef app fill:#eef8ee,stroke:#4aa35a;
  classDef data fill:#fff7e6,stroke:#caa64a;
  classDef fw fill:#fff0f0,stroke:#e06666;
  classDef nfw fill:#ffecec,stroke:#d9534f,stroke-width:1.5;
  classDef nat fill:#fff,stroke:#888;
  classDef igw fill:#fff,stroke:#888;
  classDef s3 fill:#f0fff4,stroke:#7db47d;
  classDef lb fill:#eef2ff,stroke:#6574cd,stroke-width:1.5;

```