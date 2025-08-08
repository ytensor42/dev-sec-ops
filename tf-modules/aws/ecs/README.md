## `aws/ecs` module

- ECS module
- Limitations
  - `FARGATE` only
  - ALB will be created

### Source
  ```
  module "ecs" {
    source = "git@github.com:ytensor42/dev-sec-ops.git//tf-modules/aws/ecs"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |`vpc_name`|str|_null_|VPC name|
  |`app_name`|str|_null_|APP name|
  |`public_zone_name`|str|_null_|Public zone name|
  |`cpu`|number|`1024`|CPU size|
  |`memory`|number|`2048`|Memory size|
  |`cpu_architecture`|str|`"X86_64"`|Architecture, `"X86_64"`, `"ARM64"`|
  |`container`|obj|_null_|Container definition|
  |`container_port`|number|`5000`|Container port|
  |`certificate_arn`|str|_null_|https certificate ARN for APP FQDN|
  |`service_sg_ids`|list|_null_|Security groups for service|
  |`alb_sg_ids`|list|_null_|Security groups for ALB|

### Outputs

  |name|type|comments|
  |----|----|--------|
  |`alb_dns_name`|str|ALB DNS name|
  |`service_url`|str|APP service URL|
