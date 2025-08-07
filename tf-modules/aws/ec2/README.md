## `aws/ec2` module

-  EC2 instance module

### Source
  ```
  module "ec2" {
    source = "git@github.com:ytensor42/demos.git//tf-modules/aws/ec2"
  }
  ```

### Variables

  |name|type|default|comments|
  |---|---|---|---|
  |`ami`|str|`ami-0ec1bf4a8f92e7bd1` _(ubuntu2204)_|ami id|
  |`ami_type`|str|`ubuntu-2204`|ami type (`ami_dict`)|
  |`instance_type`|str|`t2.micro`|instance type|
  |`iam_instance_profile`|str|`instance_role_ssm`|instance profile|
  |`key_name`|str|`ec2_rsa`|key name|
  |`associate_public_ip_address`|bool|`false`|public IP address|
  |`aws_subnet_id`|str|`""`|subnet id|
  |`vpc_security_group_ids`|list|`[]`|list of security group ids|
  |`volume_size`|int|`8`|volume size in G|
  |`volume_type`|str|`standard`|volume type|
  |`instance_name`|str|`demo-instance`|instance name|
  |`zone_name`|str|_null_|private zone name|
  |`http_tokens`|str|`required`|IMDS v2|
  |`user_data`|str|`null`|userdata script|

### Local constants

  |name|type|comments|
  |----|----|--------|
  |`user_data_dict`|dict|userdata dictionary|
  |`ami_dict`|dict|ami type dictionary|

#### `user_data_dict`
  - `null`
    ```
    _null_
    ```

  - `ubuntu-default`
    ```
    #!/bin/bash
    apt-get update -y
    apt install git -y
    snap enable amazon-ssm-agent
    snap restart amazon-ssm-agent
    ```

  - `amazon-default`
    ```
    #!/bin/bash
    yum update -y
    yum install git -y
    snap enable amazon-ssm-agent
    snap restart amazon-ssm-agent
    ```

  - `ubuntu-docker`
    ```
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
    ```

  - `ubuntu-test`
    ```
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
    ```

  - `ubuntu-test`
    ```
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    echo "<h1></h1><p><strong>Hostname</strong>$(hostname)</p><p><strong>IP Address</strong>$(hostname -l | cut -d" " -f1)</p>" > /var/www/html/index.html
    systemctl restart apache2
    snap enable amazon-ssm-agent
    snap restart amazon-ssm-agent
    ```

#### `ami_dict`

  |key|value|
  |---|-----|
  |`al2023`|`ami-055486c5d70a0914c`|
  |`amzn2`|`ami-05dc67d613ea82750`|
  |`ubuntu-2004`|`ami-0a15226b1f7f23580`|
  |`ubuntu-2204`|`ami-0597e0308dc02ed24`|
  |`ubuntu-2404`|`ami-01c276c8e835125d1`|


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
