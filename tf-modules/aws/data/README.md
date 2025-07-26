## `aws/data/ami` module

- AMI data module

### Source
  ```
  module "ami" {
    source = "git@github.com:ytensor42/demos.git//tf-modules/aws/data/ami"
  }
  ```

### Variables
  ```
  N/A
  ```

### Outputs

  |name|type|comments|
  |---|---|---|
  |`ami`|object|ami information|
  |`ami.ubuntu-2004`|str|ubuntu-2004 ami id|
  |`ami.ubuntu-2204`|str|ubuntu-2204 ami id|
  |`ami.ubuntu-2404`|str|ubuntu-2404 ami id|
  |`ami.amzn2`|str|amzn2 ami id|
  |`ami.al2023`|str|al2023 ami id|


## `aws/data/domain` module

- Domain zone data module

### Source
  ```
  module "domain" {
    source = "git@github.com:ytensor42/demos.git//tf-modules/aws/data/domain"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |domain_name|str|*`_null_`*|domain name|
  |private_zone|bool|`true`|private_zone flag|


### Outputs

  |name|type|comments|
  |---|---|---|
  |`zone`|object|zone information|
  |`zone.id`|str|zone id|
  |`zone.name`|str|domain name of the zone|


## `aws/data/ec2` module

- EC2 data module

### Source
  ```
  module "ec2" {
    source = "git@github.com:ytensor42/demos.git//tf-modules/aws/data/ec2"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |instance_name|str|_null_|instance name|

### Outputs

  |name|type|comments|
  |---|---|---|
  |`id`|str|instance id|
  |`ami`|str|AMI|
  |`private_ip`|str|private IP address|
  |`private_dns_name`|str|private DNS name|
  |`public_ip`|str|public IP address|
  |`public_dns_name`|str|public DNS name|
  |`vpc_security_group_ids`|list(str)|Non VPC associated security groups|
  |`subnet_id`|str|subnet id|
  |`availability_zone`|str|availability zone|


## `aws/data/vpc` module

- VPC data module

### Source
  ```
  module "vpc" {
    source = "git@github.com:ytensor42/demos.git//tf-modules/aws/data/vpc"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |vpc_name|str|`demo`|vpc name|

### Outputs

  |name|type|comments|
  |---|---|---|
  |`vpc_id`|str|vpc id|
  |`subnet_ids`|list(str)|subnet ids|
  |`subnet_cidrs`|list(str)|subnet CIDRs|
  |`rt_ids`|list(str)|subnet route table IDs|
  |`public_subnet_availability_zone`|list(str)|public subnet availability zones|
  |`public_subnet_ids`|list(str)|public subnet ids|
  |`public_subnet_cidrs`|list(str)|public subnet CIDRs|
  |`public_rt_ids`|list(str)|public subnet route table IDs|
  |`private_subnet_availability_zone`|list(str)|private subnet availability zones|
  |`private_subnet_ids`|list(str)|private subnet ids|
  |`private_subnet_cidrs`|list(str)|private subnet CIDRs|
  |`private_rt_ids`|list(str)|private subnet route table IDs|
