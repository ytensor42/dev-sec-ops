variable "ami" {
  type = string
  default = null
}

variable "ami_type" {
  type = string
  default = "ubuntu-2204"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "iam_instance_profile" {
  type = string
  default = "instance_role_ssm"
}

variable "key_name" {
  type = string
  default = "T6.local"
}

variable "associate_public_ip_address" {
  type = bool
  default = false
}

variable "aws_subnet_id" {
  type = string
  default = ""
}

variable "vpc_security_group_ids" {
  type = list
  default = []
}

variable "volume_size" {
  type = number
  default = 8
}

variable "volume_type" {
  type = string
  default = "standard"
}

variable "instance_name" {
  type = string
  default = "demo-instance"
}

variable "domain_zone" {
  type = object({
    id = string
    name = string
  })
  default = null
}

variable "http_tokens" {
  type = string
  default = "required"
}

variable "user_data" {
  default = "null"
}

locals {
  user_data_dict = {
    "null" = null
    "ubuntu-default" = <<EOF
#!/bin/bash
apt-get update -y
apt install git -y
snap enable amazon-ssm-agent
snap restart amazon-ssm-agent
EOF
    "amazon-default" = <<EOF
#!/bin/bash
yum update -y
yum install git -y
snap enable amazon-ssm-agent
snap restart amazon-ssm-agent
EOF
    "ubuntu-docker" = <<EOF
#!/bin/bash
apt-get update -y
apt-get install ca-certificates curl gnupg lsb-release -y
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
chmod a+r /etc/apt/keyrings/docker.gpg
apt-get update -y
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
apt install git -y
usermod -aG docker ubuntu
snap enable amazon-ssm-agent
snap restart amazon-ssm-agent
apt update -y
apt install -y python3-dev python3-venv git nodejs awscli
sudo su - ubuntu bash -c 'aws s3 cp s3://ytensor42-common/config/web-app.tgz /home/ubuntu/'
EOF
    "ubuntu-test" = <<EOF
#!/bin/bash
apt-get update -y
apt install python3.8-venv git -y

touch /home/ubuntu/config.sh
chmod +x /home/ubuntu/config.sh
chown ubuntu:ubuntu /home/ubuntu/config.sh
cat >> /home/ubuntu/config.sh <<EXIT
#!/bin/bash
python3 -m venv web
cd web

cat >> requirements.txt <<ENDFILE1
anyio==3.6.1
certifi==2022.9.24
charset-normalizer==2.1.1
click==8.1.3
fastapi==0.85.1
h11==0.14.0
idna==3.4
Jinja2==3.1.2
MarkupSafe==2.1.1
pydantic==1.10.2
requests==2.28.1
sniffio==1.3.0
starlette==0.20.4
typing_extensions==4.4.0
urllib3==1.26.12
uvicorn==0.18.3
ENDFILE1

/home/ubuntu/web/bin/pip install -r requirements.txt

mkdir /home/ubuntu/web/app
cd /home/ubuntu/web/app
cat >> main.py <<ENDFILE2
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

from pydantic import BaseModel

import uvicorn
import requests

app = FastAPI()

@app.get("/")
def root():
    return {"Hello": "Ubuntu"}

@app.get("/healthz/ready")
def healthz():
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
ENDFILE2

nohup /home/ubuntu/web/bin/uvicorn main:app --host 0.0.0.0 --port 8000 &
EXIT

cd /home/ubuntu/
su -c '/home/ubuntu/config.sh' ubuntu
snap enable amazon-ssm-agent
snap restart amazon-ssm-agent
EOF
    "ubuntu-apache" = <<EOF
#!/bin/bash
apt update -y
apt install apache2 -y
echo "<h1></h1><p><strong>Hostname</strong>$(hostname)</p><p><strong>IP Address</strong>$(hostname -l | cut -d" " -f1)</p>" > /var/www/html/index.html
systemctl restart apache2
snap enable amazon-ssm-agent
snap restart amazon-ssm-agent
EOF

  }

  ami_dict = {
    "al2023" = "ami-055486c5d70a0914c"
    "amzn2" = "ami-05dc67d613ea82750"
    "ubuntu-2004" = "ami-0a15226b1f7f23580"
    "ubuntu-2204" = "ami-0597e0308dc02ed24"
    "ubuntu-2404" = "ami-01c276c8e835125d1"
  }
}

