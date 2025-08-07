# AWS VPN

- [AWS Client VPN](#aws-client-vpn)
    - Open VPN client to single VPC
- [AWS VPN using Virtual Private Gateway (VGW)](#aws-vpn-using-virtual-private-gateway)
    - Single VPC to on-prem, AWS VPC, GCP, Azure
    - BGP, PSK
- [AWS VPN using Transit Gateway (TGW)](#aws-vpn-using-transit-gateway)
    - Multi VPCs to on-prem, AWS VPC, GCP, Azure
    - BGP, PSK

---
### Comparison

| Category | AWS Client VPN | Virtual Private Gateway | Transit Gateway |
|---|---|---|---|
| Concept | Managed SSL VPN endpoint for client devices | VPN endpoint for Site-to-Site connection | Central routing hub for multiple networks |
| Target |• Single VPC<br>• Remote clients(OpenVPN)|• Single VPC<br>• On-prem|• Multiple VPCs<br>• On-prem<br>• Direct Connect|
| Scalability | High | Low | High |
| Authentication |• Certificate<br>• SAML|• BGP<br>• PSK|• BGP<br>• PSK|
| Public IP Needed | No | Yes (CGW) | Yes (on-prem) |
| Main Terraform Resources |<font size="1">• aws_ec2_client_vpn_endpoint<br>• aws_ec2_client_vpn_network_association<br>• aws_ec2_client_vpn_route<br>• aws_ec2_client_vpn_authorization_rule</font>|<font size="1">• aws_vpn_gateway<br>• aws_customer_gateway<br>• aws_vpn_connection<br>• aws_vpn_connection_route</font>|<font size="1">• aws_ec2_transit_gateway<br>• aws_customer_gateway<br>• aws_vpn_connection<br>• aws_ec2_transit_gateway_vpc_attachment<br>• aws_ec2_transit_gateway_route_table<br>• aws_ec2_transit_gateway_route_table_association<br>• aws_ec2_transit_gateway_route_table_propagation<br>• aws_ec2_transit_gateway_route</font>|
| Attachment |<font size="1">aws_ec2_client_vpn_network_association<br>(to subnet)</font>|<font size="1">aws_vpn_gateway<br>(attached to VPC)</font>|<font size="1">aws_ec2_transit_gateway_vpc_attachment</font>|
| Route Configuration |• Client VPN route<br>• Authorization rule| VPC route to VGW |• TGW route table<br>• VPC route table |
| Use Case |• Remote developer access<br>• Flexible SSL VPN|• Simple on-prem to cloud VPN<br>• Site-to-other cloud vendor(GCP, Azure,...)|• Large-scale hybrid cloud<br>• Multi-account networks |

---
## AWS Client VPN

### Description
  - AWS Client VPN is a fully managed, scalable, and secure VPN service that enables remote users (e.g., developers, administrators, contractors) to securely connect to AWS resources and on-premises networks using the OpenVPN protocol
  - It eliminates the need to provision and manage traditional VPN infrastructure

#### 1. Diagram
![AWS Client VPN](./../images/vpn-aws-client.png)

#### 2. Features
  - Fully managed by AWS — no need to deploy or manage VPN servers
  - OpenVPN-based — compatible with standard OpenVPN clients (Windows, macOS, Linux)
  - Authentication options — mutual TLS, SAML 2.0, and Active Directory integration
  - Split-tunnel or full-tunnel support — control traffic routing per use case
  - Access to AWS and on-premises networks — integrate with TGW/VGW/Site-to-Site VPN
  - Highly available and elastic — automatically scales to handle more connections
  - Fine-grained access control — based on CIDR blocks and security groups
  - CloudWatch logging — connection logs for audit and monitoring

#### 3. Common Use Cases
  - Secure remote access to AWS resources for remote workers or contractors
  - VPC access for developers and operators without using bastion hosts
  - Hybrid network access — connect to both AWS and on-premises environments
  - Zero trust or identity-based security models for internal applications
  - Multi-region or global team access with centralized VPN management

#### 4. Limitations
  - No support for UDP-based applications other than OpenVPN (e.g., VoIP, some real-time apps)
  - No direct peering with VPC endpoints (must configure routing manually)
  - AWS Client VPN does not support IPv6 — only IPv4 traffic is allowed
  - Not available in all AWS Regions — regional availability may vary
  - Limited protocol support — only OpenVPN (SSL/TLS); no IPSec/IKEv2
  - Limited bandwidth per client — suitable for typical admin/dev use, not high-throughput needs
  - Split-tunnel is optional — but full-tunnel routing requires manual setup and care
  - No native support for device posture checks (e.g., device health, antivirus status)
  - Client configuration file management must be handled manually (unless SAML is used)
  - SAML auth requires additional IdP setup — adds complexity for federated access
  - Per-user logging granularity may be limited without CloudWatch + custom log processing
  - Pricing is per connection-hour — can become expensive for large, always-on deployments

#### 5. Terraform Key Resources

    resource "aws_security_group" "client_vpn_sg" {
      name        = "client-vpn-ep-sg"
      description = "Allow OpenVPN client traffic"
      vpc_id      = var.vpc_id

      ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    resource "aws_ec2_client_vpn_endpoint" "vpn" {
      description            = "AWS Client VPN"
      server_certificate_arn = var.server_certificate_arn
      authentication_options {
        type                       = "certificate-authentication"
        root_certificate_chain_arn = var.root_certificate_chain_arn
      }
      client_cidr_block      = "a.a.a.a/a"              # client cidr block
      connection_log_options {
        enabled = false
      }
      split_tunnel           = true
      vpc_id                 = var.vpc_id
      security_group_ids     = [aws_security_group.client_vpn_sg.id]
    }

    resource "aws_ec2_client_vpn_network_association" "assoc" {
      client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
      subnet_id              = var.private_subnet_id
    }

    resource "aws_ec2_client_vpn_route" "route" {
      client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
      destination_cidr_block = "x.x.x.x/x"              # VPC cidr block
      target_vpc_subnet_id   = var.private_subnet_id
    }

    resource "aws_ec2_client_vpn_authorization_rule" "auth" {
      client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
      target_network_cidr    = "x.x.x.x/x"              # VPC cidr block
      authorize_all_groups   = true
    }

---
### VPN Certificates

1. EasyRSA setup

    ```
    git clone https://github.com/OpenVPN/easy-rsa.git
    cd easy-rsa/easyrsa3
    ./easyrsa init-pki
    ```

    - This creates a new PKI (Public Key Infrastructure) directory.
    - The working directory will contain certificate files.

2. Build CA (Certificate Authority)

    ```
    ./easyrsa build-ca nopass
    ```

    - This generates the CA private key and root certificate
    - Files created:
        - `pki/ca.crt` — Root CA certificate
        - `pki/private/ca.key` — Root CA private key (unencrypted)

3. Generate the Server Certificate (for AWS VPN server)

    ```
    ./easyrsa build-server-full server nopass
    ```

    - This signs the server certificate using the root CA
    - Files created:
        - `pki/issued/server.crt` — Server certificate
        - `pki/private/server.key` — Server private key (unencrypted)

4. Prepare Files for AWS ACM Import (Server Side)

    - `server_certificate_arn`
        - `server.crt` — Certificate
        - `server.key` — Private key (must be unencrypted)
        - `ca.crt` — Certificate chain (root CA)
        ```
        aws acm import-certificate \
            --certificate fileb://pki/issued/server.crt \
            --private-key fileb://pki/private/server.key \
            --certificate-chain fileb://pki/ca.crt \
            --region <aws-region>
        ```

    - `root_certificate_chain_arn`
        - `ca.crt` — Certificate chain (root CA)
        - `private/ca.key` — dummy key to pass acm import
        ```
        aws acm import-certificate \
            --certificate fileb://pki/ca.crt \
            --private-key fileb://pki/private/ca.key \
            --region <aws-region>
        ```

5. Client Certificate (for VPN client)

    ```
    ./easyrsa build-client-full client1 nopass
    ```

    - This signs the client certificate using the same CA
    - Files created:
        - `pki/issued/client1.crt` — Client certificate
        - `pki/private/client1.key` — Client private key (unencrypted)
    - Provide `client1.crt`, `client1.key`, and `ca.crt` to users in `.ovpn` configuration

---
### OpenVPN client

1. MacOS
    - Tunnelblick (Free, GUI-based)
        - Download from the official website: https://tunnelblick.net/downloads.html
        - Open the `.dmg` and move Tunnelblick to the Applications folder
        - Launch Tunnelblick and approve any permission prompts (may need admin access)
    - CLI-based
        ```
        brew install openvpn
        ```

2. Ubuntu / Debian
    ```
    sudo apt update
    sudo apt install openvpn -y
    ```

3. RHEL / CentOS / AlmaLinux
    ```
    sudo yum install epel-release -y
    sudo yum install openvpn -y
    ```

4. Windows
    - Official site: https://openvpn.net/community-downloads/
    - Download and install the Windows Installer version

5. Configuration
    - Place `client.crt`, `client.key`, `ca.crt` in same directory and create `client.ovpn` file
        - Windows : `C:\Program Files\OpenVPN\config\`
        - Store files securely (never commit to Git!)
        - Restrict file permissions:
            ```
            chmod 600 *.crt *.key *.ovpn
            ```
    - Connect
        ```
        cd <vpn-config-folder>
        sudo openvpn --config client.ovpn
        ```
    - Sample `client.ovpn` file (*configure `remote` and other parameters properly*)
        ```
        client
        dev tun
        proto udp
        remote vpn.example.com 1194
        resolv-retry infinite
        nobind
        persist-key
        persist-tun
        remote-cert-tls server

        ca ca.crt
        cert client.crt
        key client.key

        cipher AES-256-CBC
        auth SHA256
        comp-lzo
        verb 3
        ```

---
## AWS VPN using Virtual Private Gateway

### Description
  - A Virtual Private Gateway (VGW) is an AWS-managed VPN endpoint attached to a VPC that enables connectivity between AWS and an on-premises network using IPSec Site-to-Site VPN
  - It is often paired with a Customer Gateway (CGW) device on the customer’s side and supports encrypted traffic over the public internet

#### 1. Diagram

![AWS VPN using Virtual Private Gateway](./../images/vpn-vgw.png)

#### 2. Features

  - IPSec Site-to-Site VPN support — secure encrypted tunnels over the internet
  - Redundant tunnels (2 per VPN connection) for high availability
  - Integration with VGW, Direct Connect, or Transit Gateway
  - Static or BGP-based dynamic routing (supports route propagation to VPC route tables)
  - Quick setup — no need to deploy customer hardware inside AWS
  - Compatible with a wide range of on-premises devices (Cisco, Fortinet, pfSense, etc.)
  - Supports multiple VPN connections to a single VGW

#### 3. Common Use Cases

  - Hybrid cloud architectures — extend an on-premises network into AWS
  - Disaster recovery or backup connectivity between datacenter and cloud
  - Secure tunneling of sensitive enterprise workloads to AWS
  - Allowing legacy systems to connect with AWS-hosted services
  - Failover path for AWS Direct Connect (VGW-based VPN used as backup)

#### 4. Limitations

  - Only supports IP-based communication (no multicast)
  - Throughput is limited (~1.25 Gbps per tunnel) — may be lower depending on latency
  - No SSL-based VPN — only supports IPsec/IKEv1 or IKEv2
  - Cannot terminate client VPN sessions — only site-to-site VPNs supported
  - No fine-grained user-level access control — VPN is network-level only
  - Limited to one VGW per VPC (unless using Transit Gateway)
  - High availability depends on customer gateway redundancy
  - Requires public IP on customer gateway side (or static CGW config)
  - Not ideal for dynamic endpoint IPs — best with static or predictable IPs

#### 5. Terraform Key Resources

    resource "aws_vpn_gateway" "main" {
      vpc_id = var.vpc_id
    }

    resource "aws_customer_gateway" "cgw" {
      bgp_asn    = 65000
      ip_address = "a.a.a.a"                                # remote gateway IP
      type       = "ipsec.1"
    }

    resource "aws_vpn_connection" "vpn" {
      vpn_gateway_id        = aws_vpn_gateway.main.id
      customer_gateway_id   = aws_customer_gateway.cgw.id
      type                  = "ipsec.1"
      static_routes_only    = true                          # false - dynamic routing, BGP
      tunnel1_preshared_key = "<psk key 1>"
      tunnel1_inside_cidr   = "<inside cide 1>"
      tunnel2_preshared_key = "<psk key 2>"
      tunnel2_inside_cidr   = "<inside cide 2>"
    }

    resource "aws_vpn_connection_route" "vpc_route" {       # only need when `static_routes_only = true`
      vpn_connection_id      = aws_vpn_connection.vpn.id
      destination_cidr_block = "y.y.y.y/y"                  # VPC CIDR
    }

    resource "aws_route" "vpn_route" {
      route_table_id         = vpc.private_rt_id
      destination_cidr_block = "z.z.z.z/z"                  # remote CIDR
      gateway_id             = aws_vpn_gateway.main.id
    }

---
## AWS VPN using Transit Gateway

### Description
  - AWS Transit Gateway (TGW) is a highly scalable, cloud-native hub that connects multiple VPCs, VPNs, and AWS Direct Connect links through a central gateway
  - A VPN connection to a Transit Gateway enables encrypted Site-to-Site IPsec connectivity between on-premises networks and AWS, with the TGW acting as the central router for all attached networks

#### 1. Diagram

  ![AWS VPN using Transit Gateway](./../images/vpn-tgw.png)

#### 2. Features
  - Hub-and-spoke architecture — connects multiple VPCs and on-prem networks via one gateway
  - Supports Site-to-Site IPsec VPN (2 tunnels per VPN connection for HA)
  - Scales to thousands of VPCs and attachments
  - Attachment-based routing — enables segmented routing domains (route tables per attachment)
  - BGP (dynamic) or static routing support
  - Integration with AWS Direct Connect, VGW, and Client VPN
  - Cross-account and cross-region VPC connectivity via attachments and peering
  - Built-in high availability across multiple AZs

#### 3. Common Use Cases

  - Large-scale enterprise networks with dozens or hundreds of VPCs
  - Centralized hybrid connectivity (on-premises ↔ multiple VPCs)
  - Simplifying VPC-to-VPC peering by using TGW as a central router
  - Multi-region network architectures (via TGW peering)
  - Migration and failover between environments (e.g., prod/stage/dev)
  - Enabling segmentation and network isolation with multiple TGW route tables

#### 4. Limitations

  - Higher cost compared to VGW or VPC peering (charged per attachment and data)
  - VPN throughput is limited (~1.25 Gbps per tunnel) — same as VGW
  - No SSL/TLS VPN support — only IPsec IKEv1/IKEv2
  - Requires separate setup for DNS resolution between attached networks
  - TGW is a regional resource — cross-region requires TGW peering
  - Requires careful routing table design — complexity increases with scale
  - Attachment propagation doesn't imply automatic access — must configure routes explicitly
  - AWS Transit Gateway Connect (for SD-WAN) is a separate feature and adds cost

#### 5. Terraform Key Resources

    resource "aws_ec2_transit_gateway" "main" {
      description = "main"
    }

    resource "aws_customer_gateway" "cgw" {
      bgp_asn    = 65000
      ip_address = "a.a.a.a"                              # remote gateway IP
      type       = "ipsec.1"
    }

    resource "aws_vpn_connection" "vpn" {
      customer_gateway_id = aws_customer_gateway.cgw.id
      transit_gateway_id  = aws_ec2_transit_gateway.main.id
      type                = "ipsec.1"
      static_routes_only  = true
    }

    resource "aws_ec2_transit_gateway_vpc_attachment" "vpc" {
      transit_gateway_id = aws_ec2_transit_gateway.main.id
      vpc_id             = var.vpc_id
      subnet_ids         = var.vpc_subnet_ids
    }

    resource "aws_ec2_transit_gateway_route_table" "main" {
      transit_gateway_id = aws_ec2_transit_gateway.main.id
    }

    # Incoming VPN traffic to refer route table @ TGW 
    resource "aws_ec2_transit_gateway_route_table_association" "vpn_assoc" {
      transit_gateway_attachment_id = aws_vpn_connection.vpn.transit_gateway_attachment_id
      transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
    }

    # Incoming VPC traffic to refer route table @ TGW
    resource "aws_ec2_transit_gateway_route_table_association" "vpc_assoc" {
      transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.vpc.id
      transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
    }

    # For dynamic routing, BGP
    resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_propagation" {
      transit_gateway_attachment_id  = aws_vpn_connection.vpn.transit_gateway_attachment_id
      transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
    }

    # From VPN to VPC
    resource "aws_ec2_transit_gateway_route" "vpc_route" {
      destination_cidr_block         = "x.x.x.x/x"        # vpc cidr
      transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
      transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc.id
    }

    # From VPC to VPN
    resource "aws_ec2_transit_gateway_route" "vpn_route" {
      destination_cidr_block         = "y.y.y.y/y"        # remote cidr
      transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.main.id
      transit_gateway_attachment_id  = aws_vpn_connection.vpn.transit_gateway_attachment_id
    }

    # VPC internal to TGW
    resource "aws_route" "vpc_to_tgw" {
      route_table_id         = aws_route_table.private.id
      destination_cidr_block = "y.y.y.y/y"                # remote cidr
      transit_gateway_id     = aws_ec2_transit_gateway.main.id
    }
