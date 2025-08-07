# EC2 Infrastructures

## `tester` Instance

- `tester` instance for test
    - infra: `infra/aws/ec2/tester`

- SSM VPC Endpoint
    - `default` VPC private subnet

- Security Group
    - `default-sg-tester`
        - ingress TCP 22 from `default` public/private subnet CIDRs

- EC2 instance
    - Name: `default-tester`
    - AMI: Latest Ubuntu 2404 `ubuntu-2204`
    - `default` VPC private subnet
    - Instance type: `t3.micro`
    - Instance profile: `instance-profile-ssm`

---
## `webapp` Instance

- `webapp` instance for test webapp
    - infra: `infra/aws/ec2/webapp`

- SSM VPC Endpoint
    - `default` VPC private subnet

- Security Group
    - `default-sg-webapp`
        - ingress TCP 5432 from `default` private subnet CIDRs

- EC2 instance
    - Name: `default-webapp`
    - AMI: `ami-031da650a6471429e` ; webapp custom AMI
    - `default` VPC private subnet
    - Instance type: `t3.small`
    - Instance profile: `instance-profile-ssm-ecr`
