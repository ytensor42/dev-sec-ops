data "aws_ami" "ubuntu-2004" {
    # ami-07182692443fccde1
    most_recent = true
    owners = ["099720109477"] # Canonical Group
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_ami" "ubuntu-2204" {
    # ami-0ec1bf4a8f92e7bd1
    most_recent = true
    owners = ["099720109477"] # Canonical Group
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_ami" "ubuntu-2404" {
    # ami-0026a04369a3093cc
    most_recent = true
    owners = ["099720109477"] # Canonical Group
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

data "aws_ami" "amzn2" {
    most_recent = true
    owners = ["137112412989"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-gp2"]
    }
    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

data "aws_ami" "al2023" {
    most_recent = true
    owners = ["137112412989"]
    filter {
        name = "name"
        values = ["al2023-ami-*"]
    }
    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

output "ami" {
  value = {
    "ubuntu-2004": data.aws_ami.ubuntu-2004.image_id,
    "ubuntu-2204": data.aws_ami.ubuntu-2204.image_id,
    "ubuntu-2404": data.aws_ami.ubuntu-2404.image_id,
    "amzn2": data.aws_ami.amzn2.image_id,
    "al2023": data.aws_ami.al2023.image_id,
  }
}
