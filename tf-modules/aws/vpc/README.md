## `aws/vpc` module

- VPC module

### Source
  ```
  module "vpc" {
    source = "git@github.com:ytensor42/demos.git//tf-modules/aws/vpc"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |`region`|str|`us-west-2`|region|
  |`vpc_name`|str|`dev`|vpc name|
  |`vpc_cidr`|str|`10.0.0.0/16`|vpc default CIDR|
  |`public_subnet`|number|`0`|number of public subnets|
  |`private_subnet`|number|`0`|number of private subnets|
  |`nat_gw`|bool|`false`|enable NAT gw for private subnets|
  |`nat_gw_multi`|bool|`false`|enable individual NAT gw for each private subnet|
  |`ssm_vpce`|bool|`false`|create SSM VPC Endpoints for private subnets|


### Local constants

  |name|type|value|comments|
  |----|----|-----|--------|
  |`zones`|list|`["a", "b", "c", "d"]`|zone postfix|
  |`ssm_endpoints`|list|`["ssm", "ssmmessages", "ec2messages"]`|ssm endpoints|
  |`public_cidrs`|list|`[.<dynamic>.]`|public subnet CIDRs|
  |`public_zones`|list|`[.<dynamic>.]`|public zones|
  |`private_cidrs`|list|`[.<dynamic>.]`|private subnet CIDRs|
  |`private_zones`|list|`[.<dynamic>.]`|private zones|


### Outputs

  |name|type|comments|
  |---|---|---|
  |`vpc_id`|str|vpc id|
  |`subnet_ids`|list(str)|subnet ids|
  |`subnet_cidrs`|list(str)|subnet CIDRs|
  |`rt_ids`|list(str)|subnet route table IDs|
  |`public_subnet_availability_zone`|list(str)|public subnet availability zones|
  |`public_subnet_ids`|list(str)|public subnet IDs|
  |`public_subnet_cidrs`|list(str)|public subnet CIDRs|
  |`public_rt_ids`|list(str)|public subnet route table IDs|
  |`private_subnet_availability_zone`|list(str)|private subnet availability zones|
  |`private_subnet_ids`|list(str)|private subnet IDs|
  |`private_subnet_cidrs`|list(str)|private subnet CIDRs|
  |`private_rt_ids`|list(str)|private subnet route table IDs|
