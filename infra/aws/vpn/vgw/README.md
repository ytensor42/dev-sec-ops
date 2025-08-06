# AWS VPN using Virtual Private Gateway

## Description
  - A Virtual Private Gateway (VGW) is an AWS-managed VPN endpoint attached to a VPC that enables connectivity between AWS and an on-premises network using IPSec Site-to-Site VPN
  - It is often paired with a Customer Gateway (CGW) device on the customer’s side and supports encrypted traffic over the public internet

### Diagram

  ![AWS VPN using Virtual Private Gateway](./../../images/vpn-vgw.png)

### Features

  - IPSec Site-to-Site VPN support — secure encrypted tunnels over the internet
  - Redundant tunnels (2 per VPN connection) for high availability
  - Integration with VGW, Direct Connect, or Transit Gateway
  - Static or BGP-based dynamic routing (supports route propagation to VPC route tables)
  - Quick setup — no need to deploy customer hardware inside AWS
  - Compatible with a wide range of on-premises devices (Cisco, Fortinet, pfSense, etc.)
  - Supports multiple VPN connections to a single VGW

### Common Use Cases

  - Hybrid cloud architectures — extend an on-premises network into AWS
  - Disaster recovery or backup connectivity between datacenter and cloud
  - Secure tunneling of sensitive enterprise workloads to AWS
  - Allowing legacy systems to connect with AWS-hosted services
  - Failover path for AWS Direct Connect (VGW-based VPN used as backup)

### Limitations

  - Only supports IP-based communication (no multicast)
  - Throughput is limited (~1.25 Gbps per tunnel) — may be lower depending on latency
  - No SSL-based VPN — only supports IPsec/IKEv1 or IKEv2
  - Cannot terminate client VPN sessions — only site-to-site VPNs supported
  - No fine-grained user-level access control — VPN is network-level only
  - Limited to one VGW per VPC (unless using Transit Gateway)
  - High availability depends on customer gateway redundancy
  - Requires public IP on customer gateway side (or static CGW config)
  - Not ideal for dynamic endpoint IPs — best with static or predictable IPs

### Terraform Key Resources

    resource "aws_vpn_gateway" "vgw" {
      vpc_id = aws_vpc.main.id
    }

    resource "aws_customer_gateway" "cgw" {
      bgp_asn    = 65000
      ip_address = "x.x.x.x"
      type       = "ipsec.1"
    }

    resource "aws_vpn_connection" "vpn" {
      vpn_gateway_id        = aws_vpn_gateway.vgw.id
      customer_gateway_id   = aws_customer_gateway.cgw.id
      type                  = "ipsec.1"
      static_routes_only    = true                         # false - dynamic routing, BGP
      tunnel1_preshared_key = "<psk key 1>"
      tunnel1_inside_cidr   = "<inside cide 1>"
      tunnel2_preshared_key = "<psk key 2>"
      tunnel2_inside_cidr   = "<inside cide 2>"
    }

    resource "aws_vpn_connection_route" "to_vpc" {          # only need when `static_routes_only = true`
      vpn_connection_id      = aws_vpn_connection.vpn.id
      destination_cidr_block = "y.y.y.y/y"                  # VPC CIDR
    }

    resource "aws_route" "to_remote" {
      route_table_id         = vpc.private_rt_id
      destination_cidr_block = "z.z.z.z/z"                  # remote CIDR
      gateway_id             = aws_vpn_gateway.vgw.id
    }
