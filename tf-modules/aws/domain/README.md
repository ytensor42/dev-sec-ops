## `aws/domain` module

- domain zone module

### Source
  ```
  module "domain" {
    source = "git@github.com:ytensor42/dev-sec-ops.git//tf-modules/aws/domain"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |root_domain|str|`ansolute.com`|root domain name|
  |sub_domain|str|`aws`|sub domain name|
  |delegation|bool|`false`|delegation flag|
  |vpc_id|list(str)|`[]`|list of vpc-id|


### Outputs

  |name|type|comments|
  |---|---|---|
  |`value`|object|zone information|
  |`value.id`|str|zone id|
  |`value.name`|str|domain name of the zone|
