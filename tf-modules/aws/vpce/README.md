## `aws/vpce/interface` module

- VPC Endpoint module

### Source
  ```
  module "interface" {
    source = "git@github.com:ytensor42/dev-sec-ops.git//tf-modules/aws/vpce/interface"
    endpoint = "ssm"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |`region`|str|`us-west-2`|region|
  |`endpoint`|str|`ssm`|endpoint, `ssm`, `ecr`, `sm`|
  |`vpc_name`|str|`dev`|vpc name|
  |`network_name`|str|`private`|`private` or `public`|


### Local constants

  |name|type|value|comments|
  |----|----|-----|--------|
  |`network_cidrs`|list|`[.<dynamic>.]`|network CIDRs|
  |`endpoints.ssm`|list|`["ssm", "ssmmessages", "ec2messages"]`|ssm endpoints|
  |`endpoints.ecr`|list|`[ "ecr.api", "ecr.dkr" ]`|ecr endpoints|
  |`endpoints.sm`|list|`[ "secretsmanager" ]`|sm endpoints|


### Outputs

  - N/A