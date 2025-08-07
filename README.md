# Dev-Sec-Ops Examples

## Infrastructure as Code [![Terraform](https://github.com/ytensor42/dev-sec-ops/actions/workflows/terraform.yaml/badge.svg?branch=main)](https://github.com/ytensor42/dev-sec-ops/actions/workflows/terraform.yaml)

- [Terraform modules](./tf-modules/README.md)
    - github based module sources

### AWS

- [Base infrastructure](./infra/aws/base/README.md)
    - [`default` VPC](./infra/aws/base/README.md#default-vpc)
    - [NAT Gateway](./infra/aws/base/README.md#nat-gateway)
    - [SSM](./infra/aws/base/README.md#ssm-vpc-endpoint) / [ECR](./infra/aws/base/README.md#ecr-vpc-endpoint) VPC Endpoints

- [VPN](./infra/aws/vpn/README.md)
    - [AWS Client VPN](./infra/aws/vpn/README.md#aws-client-vpn)
    - [Site-to-Site with VPN Gateway](./infra/aws/vpn/README.md#aws-vpn-using-virtual-private-gateway)
    - [Site-to-Hub with Transit Gateway](./infra/aws/vpn/README.md#aws-vpn-using-transit-gateway)

- [EC2](./infra/aws/ec2/README.md)
    - [`test` instance](./infra/aws/ec2/README.md#test-instance)
    - [`dev` instance](./infra/aws/ec2/README.md#dev-instance)

- [ECS](./infra/aws/ecs/README.md)
    - [`test` instance](./infra/aws/ecs/README.md#)

- [RDS](./infra/aws/rds/README.md)
    - [`devpostgres` instance](./infra/aws/rds/README.md#devpostgres-instance)

<!---
- [VPC Peering]()
    - Peering `default` VPC and `backend` VPC
    - EC2 instance in private subnet @ each VPC
    - Route between private subnets

- [ECS provisioning]()
    - Task, Service, ALB provisioning
    - ECS Fargate instances in private subnets @ `default` VPC
    - Accessing ECR

- [EKS provisioning using `terraform`]()
    - Private subnets @ `default` VPC
    - Public accessible controller

- [EKS provisioning using `eksctl`]()
    - Private subnets @ `default` VPC
    - Public accessible controller
    - Tools installation after provisioning

- [Transit Gateway between VPCs in different AWS account]()
    - TBD

- [Single VPC internet exits for multiple VPCs using Transit Gateway]()
    - NAT GW @ `default` VPC
    - No NAT GW @ 2 other VPCs
    - Transit Gateway among all 3 VPCs
    - All outgoing traffic will be routed to `default` VPC then exit to internet

### GCP

- [Base infrastructure]()
    - Single VPC with public and private subnets on 2 availability zones

---
### CI/CD

- [Simple 3-Tier Application]()
    - *TBD*

- [VM provisioning]()
    - Private subnet
    - iAH connection

- [GKE provisioning]()
    - Private subnet

- [VPN]
    - [Site-to-Site VPN with AWS VPC]
        - *TBD*

- [Developer-controlled Github Runner using Action Runner Controller]()
    - *TBD*

### Security

- [Accessing Resource on Private Subnet using AWS SSM]()
    - No public IP address
    - No VPN
    - Direct ssh access to instance
    - Accessing backend resource using port-forwarding on private instance
- [Accessing Resource on Private Subnet using Kubernetes control plane]()
    - *TBD*

## MLOps

- Deploy model from Huggingface
-->
