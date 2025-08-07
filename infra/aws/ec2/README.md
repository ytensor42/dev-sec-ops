# EC2 Infrastructures

## `test` Instance

- `test` instance for test
    - infra: `infra/aws/ec2/tester`

- SSM VPC Endpoint
    - `default` VPC private subnet

- Security Group
    - `default-sg-test`
        - ingress TCP 22 from `default` public/private subnet CIDRs

- EC2 instance
    - Name: `default-test`
    - AMI: Latest Ubuntu 2404 `ubuntu-2204`
    - `default` VPC private subnet
    - Instance type: `t3.micro`
    - Instance profile: `instance-profile-ssm`

---
## `dev` Instance

- `dev` instance for test webapp
    - infra: `infra/aws/ec2/develop`

- SSM VPC Endpoint
    - `default` VPC private subnet

- Security Group
    - `default-sg-dev`
        - ingress TCP 5432 from `default` private subnet CIDRs

- EC2 instance
    - Name: `default-dev`
    - AMI: `ami-061e8bd551e848afc` ; dev custom AMI
    - `default` VPC private subnet
    - Instance type: `t3.micro`
    - Instance profile: `instance-profile-ssm-ecr`
