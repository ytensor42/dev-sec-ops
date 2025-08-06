# DevOps Demos

- Infrastructure as Code
    - [![Terraform](https://github.com/ytensor42/demos/actions/workflows/terraform.yaml/badge.svg?branch=main)](https://github.com/ytensor42/demos/actions/workflows/terraform.yaml)

    - [Terraform modules](./tf-modules/README.md)
        - github based module sources

    - [Base infrastructure on AWS](./infra/aws/base/README.md)
        - Single AWS VPC with public and private subnets on 2 availability zones

    - AWS VPN
        - [AWS Client VPN](./infra/aws/vpn/awsclientvpn/README.md)
            - Open VPN client to single VPC
        - [Site-to-Site with VPN Gateway](./infra/aws/vpn/vgw/README.md)
            - Single VPC to on-prem, AWS VPC, GCP, Azure
            - BGP, PSK
        - [Site-to-Hub with Transit Gateway](./infra/aws/vpn/tgw/README.md)
            - Multi VPCs to on-prem, AWS VPC, GCP, Azure
            - BGP, PSK
