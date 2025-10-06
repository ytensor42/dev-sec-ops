## VPC Diagram


### VPC

```mermaid
flowchart LR
  Internet((Internet)) --> R53[Route 53 / DNS]
  R53 --> ALB[Application Load Balancer]

  subgraph VPC[ VPC 172.20.0.0/16 ]
    direction LR

    subgraph AZa[AZ-a]
      direction TB
      PUBa[Public Subnet - ALB ENI]
      FWa[Firewall Subnet - NFW]
      APPa[Private App Subnet - Targets]
      DATAa[Private Data Subnet]
    end

    subgraph AZb[AZ-b]
      direction TB
      PUBb[Public Subnet - ALB ENI]
      FWb[Firewall Subnet - NFW]
      APPb[Private App Subnet - Targets]
      DATAb[Private Data Subnet]
    end

    subgraph AZc[AZ-c]
      direction TB
      PUBc[Public Subnet - ALB ENI]
      FWc[Firewall Subnet - NFW]
      APPc[Private App Subnet - Targets]
      DATAc[Private Data Subnet]
    end

    NAT[NAT Gateway per AZ]
    IGW[Internet Gateway]
    NFW[AWS Network Firewall Endpoint per AZ]
    S3EP[S3 VPC Endpoint - Gateway, attached to App RT]
  end

  %% ALB ENIs live in Public subnets (conceptual link)
  ALB --- PUBa
  ALB --- PUBb
  ALB --- PUBc

  %% Ingress: ALB -> App Targets (Target Group)
  ALB -->|HTTP/HTTPS| APPa
  ALB -->|HTTP/HTTPS| APPb
  ALB -->|HTTP/HTTPS| APPc

  %% Default egress path
  APPa -->|0.0.0.0/0| NFW --> NAT --> IGW
  APPb -->|0.0.0.0/0| NFW
  APPc -->|0.0.0.0/0| NFW

  %% S3 route (Gateway endpoint via App RT association)
  APPa -->|S3 prefixes| S3EP
  APPb -->|S3 prefixes| S3EP
  APPc -->|S3 prefixes| S3EP

```

### VPC with FW (in/e)gress

```mermaid
flowchart TB
  Internet((Internet)) --> R53[Route53_DNS]
  R53 --> ALB[(ALB)]

  subgraph VPC[VPC_172.20.0.0/16]
    direction LR

    subgraph AZa[AZ-a]
      direction TB
      PUBa[(Public_Subnet_ALB_ENI)]
      FWa[(Firewall_Subnet_NFW_Endpoint)]
      APPa[(Private_App_Subnet_Targets)]
      DATAa[(Private_Data_Subnet)]
    end

    NAT[(NAT_Gateway_per_AZ)]
    IGW[(Internet_Gateway)]
    NFW[(AWS_Network_Firewall)]
    S3EP[(S3_VPC_Endpoint_Gateway_attached_to_App_RT)]
  end

  %% ALB in public subnet; ingress to app targets
  ALB --- PUBa
  ALB -->|http_https| APPa

  %% App egress via firewall subnet and NAT to internet
  APPa -->|default-route| FWa
  FWa -->|inspection| NFW
  NFW --> NAT --> IGW

  %% App to S3 via Gateway endpoint (bypass NFW/NAT)
  APPa -->|s3-prefixes| S3EP

  %% styling
  classDef ext fill:#f6f6ff,stroke:#6270f0,stroke-width:1.2;
  classDef pub fill:#eefaff,stroke:#3aa0d8;
  classDef app fill:#eef8ee,stroke:#4aa35a;
  classDef data fill:#fff7e6,stroke:#caa64a;
  classDef fw fill:#fff0f0,stroke:#e06666;
  classDef fwcore fill:#ffecec,stroke:#d9534f,stroke-width:1.5;
  classDef nat fill:#fff,stroke:#888;
  classDef igw fill:#fff,stroke:#888;
  classDef s3 fill:#f0fff4,stroke:#7db47d;
  classDef lb fill:#eef2ff,stroke:#6574cd,stroke-width:1.5;

  class Internet,R53 ext;
  class PUBa pub;
  class APPa app;
  class DATAa data;
  class FWa fw;
  class NFW fwcore;
  class NAT nat;
  class IGW igw;
  class S3EP s3;
  class ALB lb;
```

### Ingress + Egress Inspection VPC

```mermaid
flowchart LR
  Internet((Internet)) --> IGW --> IngressVPC[NFW Ingress Inspection VPC] --> TGW
  TGW --> AppVPC[App VPC (ALB, App, Data)]
  AppVPC --> TGW --> EgressVPC[NFW Egress Inspection VPC] --> NATGW --> IGW
```