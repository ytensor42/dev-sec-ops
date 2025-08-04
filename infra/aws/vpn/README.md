# AWS VPN

## VPN Types and Resources

| Category | Transit Gateway (TGW) | Virtual Private Gateway (VGW) | AWS Client VPN |
|----------|------------------------|-------------------------------|----------------|
| Concept | Central routing hub for multiple networks | VPN endpoint for Site-to-Site connection | Managed SSL VPN endpoint for client devices |
| Target |• Multiple VPCs<br>• On-prem<br>• Direct Connect|• Single VPC<br>• On-prem|• Single VPC<br>• Remote clients(openvpc)|
| Scalability | High | Low | High |
| Authentication |• BGP<br>• PSK|• BGP<br>• PSK|• Certificate<br>• SAML|
| Public IP Needed | Yes (on-prem) | Yes (CGW) | No |
| Main Terraform Resources |<font size="1">• aws_ec2_transit_gateway<br>• aws_ec2_transit_gateway_vpc_attachment<br>• aws_ec2_transit_gateway_route_table</font>|<font size="1">• aws_vpn_gateway<br>• aws_customer_gateway<br>• aws_vpn_connection<br>• aws_vpn_connection_route</font>|<font size="1">• aws_ec2_client_vpn_endpoint<br>• aws_ec2_client_vpn_network_association<br>• aws_ec2_client_vpn_route<br>• aws_ec2_client_vpn_authorization_rule</font>|
| Attachment |<font size="1">aws_ec2_transit_gateway_vpc_attachment</font>|<font size="1">aws_vpn_gateway<br>(attached to VPC)</font>|<font size="1">aws_ec2_client_vpn_network_association<br>(to subnet)</font>|
| Route Configuration |• TGW route table<br>• VPC route table | VPC route to VGW |• Client VPN route<br>• Authorization rule|
| Use Case |• Large-scale hybrid cloud<br>• Multi-account networks |• Simple on-prem to cloud VPN<br>• Site-to-other cloud vendor(GCP, Azure,...)|• Remote developer access<br>• Flexible SSL VPN|


## Transit Gateway (Site-to-Hub)
```hcl
resource "aws_ec2_transit_gateway" "main" {
  description = "main"
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = "x.x.x.x"    # customer gateway ip
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn" {
  customer_gateway_id = aws_customer_gateway.cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachment1" {
  subnet_ids         = var.vpc1_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc1_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "attachment2" {
  subnet_ids         = var.vpc2_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc2_id
}

resource "aws_ec2_transit_gateway_route_table" "rt" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
}

resource "aws_ec2_transit_gateway_route" "tgw_route1" {
  destination_cidr_block         = "192.168.100.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment1.id
}

resource "aws_ec2_transit_gateway_route" "tgw_route2" {
  destination_cidr_block         = "192.168.200.0/24"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.attachment2.id
}

resource "aws_route" "vpc1_to_tgw" {
  route_table_id         = aws_route_table.private1.id
  destination_cidr_block = "192.168.100.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "vpc2_to_tgw" {
  route_table_id         = aws_route_table.private2.id
  destination_cidr_block = "192.168.200.0/24"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}
```

## Virtual Private Gateway (Site-to-VPC)
```hcl
resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = "203.0.113.12"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.cgw.id
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_vpn_connection_route" "route" {
  vpn_connection_id      = aws_vpn_connection.vpn.id
  destination_cidr_block = "10.0.0.0/16"
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "192.168.100.0/24"
    gateway_id = aws_vpn_gateway.vgw.id
  }
}
```

## AWS Client VPN (Client-to-VPC)
```hcl
resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description              = "Client VPN"
  server_certificate_arn  = var.server_cert_arn
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_ca_arn
  }
  client_cidr_block        = "10.11.0.0/16"
  connection_log_options {
    enabled = false
  }
  split_tunnel             = true
  vpc_id                   = var.vpc_id
  security_group_ids       = [aws_security_group.vpn_sg.id]
}

resource "aws_ec2_client_vpn_network_association" "assoc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = var.subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "auth" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = "10.0.0.0/16"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_route" "route" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  destination_cidr_block = "10.0.0.0/16"
  target_vpc_subnet_id   = var.subnet_id
}
```

