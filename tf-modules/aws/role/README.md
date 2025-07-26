## `aws/role/instance_profile` module

- Instance Profile module

### Source
  ```
  module "instance_profile" {
    source = "git@github.com:ytensor42/demos.git//tf-modules/aws/role/instance_profile"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |`name_postfix`|str|`""`|name postfix|
  |`policy_arns`|list|`[]`|list of policy ARNs|

### Outputs

  |name|type|comments|
  |---|---|---|
  |`role_name`|str|instance role name|
  |`profile_name`|str|instance profile name|
