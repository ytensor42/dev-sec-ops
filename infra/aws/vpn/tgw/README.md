# AWS VPN using Transit Gateway

## Description
  - AWS Transit Gateway (TGW) is a highly scalable, cloud-native hub that connects multiple VPCs, VPNs, and AWS Direct Connect links through a central gateway
  - A VPN connection to a Transit Gateway enables encrypted Site-to-Site IPsec connectivity between on-premises networks and AWS, with the TGW acting as the central router for all attached networks

### Diagram

  ![AWS VPN using Transit Gateway](./../../images/vpn-tgw.png)

### Features
  - Hub-and-spoke architecture — connects multiple VPCs and on-prem networks via one gateway
  - Supports Site-to-Site IPsec VPN (2 tunnels per VPN connection for HA)
  - Scales to thousands of VPCs and attachments
  - Attachment-based routing — enables segmented routing domains (route tables per attachment)
  - BGP (dynamic) or static routing support
  - Integration with AWS Direct Connect, VGW, and Client VPN
  - Cross-account and cross-region VPC connectivity via attachments and peering
  - Built-in high availability across multiple AZs

### Common Use Cases

  - Large-scale enterprise networks with dozens or hundreds of VPCs
  - Centralized hybrid connectivity (on-premises ↔ multiple VPCs)
  - Simplifying VPC-to-VPC peering by using TGW as a central router
  - Multi-region network architectures (via TGW peering)
  - Migration and failover between environments (e.g., prod/stage/dev)
  - Enabling segmentation and network isolation with multiple TGW route tables

### Limitations

  - Higher cost compared to VGW or VPC peering (charged per attachment and data)
  - VPN throughput is limited (~1.25 Gbps per tunnel) — same as VGW
  - No SSL/TLS VPN support — only IPsec IKEv1/IKEv2
  - Requires separate setup for DNS resolution between attached networks
  - TGW is a regional resource — cross-region requires TGW peering
  - Requires careful routing table design — complexity increases with scale
  - Attachment propagation doesn't imply automatic access — must configure routes explicitly
  - AWS Transit Gateway Connect (for SD-WAN) is a separate feature and adds cost

### Terraform Key Resources

    resource "aws_ec2_transit_gateway" "main" {
      description = "main"
    }

    resource "aws_customer_gateway" "cgw" {
      bgp_asn    = 65000
      ip_address = "x.x.x.x"
      type       = "ipsec.1"
    }

    resource "aws_vpn_connection" "vpn" {
      customer_gateway_id = aws_customer_gateway.cgw.id
      transit_gateway_id  = aws_ec2_transit_gateway.main.id
      type                = "ipsec.1"
      static_routes_only  = true
    }

    resource "aws_ec2_transit_gateway_vpc_attachment" "attachment" {
      subnet_ids         = var.vpc_subnet_ids
      transit_gateway_id = aws_ec2_transit_gateway.main.id
      vpc_id             = var.vpc_id
    }

    resource "aws_ec2_transit_gateway_route_table" "rt" {
      transit_gateway_id = aws_ec2_transit_gateway.main.id
    }

    resource "aws_ec2_transit_gateway_route" "tgw_route" {
      destination_cidr_block         = "y.y.y.y/y"
      transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
      transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment.id
    }

    resource "aws_route" "vpc_to_tgw" {
      route_table_id         = aws_route_table.private.id
      destination_cidr_block = "y.y.y.y/y"
      transit_gateway_id     = aws_ec2_transit_gateway.main.id
    }
