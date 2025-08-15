# RDS Instances

## `devpostgres` Instance

- RDS postgres instance @ `default` VPC
    - infra: `infra/aws/rds/devpostgres`

- Security Group
    - `default-sg-devpostgres`
        - ingress open (TCP 5432) to RFC1918 addresses (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`)

- RDS instance
    - Name: `default-devpostgres`
    - Version: 17.5
    - No public access
    - Single AZ
    - `default` VPC private subnet
    - Instance type: `db.t3.micro`
    - DB subnet group
        - `default` private subnets

    - Arguments
        |Argument|Value|
        |---|---|
        |`identifier`|`"dev-postgres"`|
        |`engine`|`"postgres"`|
        |`engine_version`|`"17.5"`|
        |`instance_class`|`"db.t3.micro"`|
        |`ca_cert_identifier`|`"rds-ca-rsa2048-g1"`|
        |`allocated_storage`|`20`|
        |`storage_type`|`"gp2"`|
        |`storage_encrypted`|`true`|
        |`db_subnet_group_name`|_(subnet group name)_|
        |`vpc_security_group_ids`|_(security group ids)_|
        |`publicly_accessible`|`false`|
        |`skip_final_snapshot`|`true`|
        |`db_name`|_(from secret manager)_|
        |`username`|_(from secret manager)_|
        |`password`|_(from secret manager)_|
        |`port`|_(from secret manager)_|
        |`parameter_group_name`|`"default.postgres17"`|
        |`network_type`|`"IPV4"`|
        |`multi_az`|`false`|
        |`backup_retention_period`|`0`|
        |`auto_minor_version_upgrade`|`true`|
        |`maintenance_window`|`"sun:03:00-sun:04:00"`|
        |`deletion_protection`|`false`|
        |`performance_insights_enabled`|`false`|
        |`monitoring_interval`|`0`|

    - Outputs
        |Attribute|Description|
        |---|---|
        |`address`|db instance host address|
        |`fqdn`|Public CNAME address|
