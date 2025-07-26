# Terraform modules

## Contents

|Folder|Contents|
|---|---|
|`aws/domain`|[AWS domain module](aws/domain/README.md)|
|`aws/ec2`|[AWS EC2 module](aws/ec2/README.md)|
|`aws/role/instance_profile`|[AWS Role / instance profile module](aws/role/README.md#awsroleinstance_profile-module)|
|`aws/vpc`|[AWS VPC module](aws/vpc/README.md)|
|`aws/vpce/interface`|[AWS VPC Endpoint - interface type](aws/vpce/README.md#awsvpceinterface-module)|
|`aws/data/ami`|[AWS AMI data module](aws/data/README.md#awsdataami-module)|
|`aws/data/domain`|[AWS domain data module](aws/data/README.md#awsdatadomain-module)|
|`aws/data/ec2`|[AWS EC2 data module](aws/data/README.md#awsdataec2-module)|
|`aws/data/vpc`|[AWS VPC data module](aws/data/README.md#awsdatavpc-module)|
|`gcp/vm`|[GCP VM module](gcp/vm/README.md)|
|`azure/`|Azure module base (_TBD_)|

## TFState

- S3
```
terraform {
  backend "s3" {
    bucket = "<bucket-name>"
    key = "terraform-state/<project>/<task>/tfstate"
    region = "<aws-region>"
  }
}
```

- Terraform Cloud
```
terraform {
  cloud {
    organization = "<organization-name>"
    workspaces {
      name = "<workspace-name>"
    }
  }
}
```