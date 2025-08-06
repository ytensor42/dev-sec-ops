# AWS VPN

## VPN Types and Resources

- [AWS Client VPN](./awsclientvpn/README.md)
- [AWS VPN using Virtual Private Gateway (VGW)](./vgw/README.md)
- [AWS VPN using Transit Gateway (TGW)](./tgw/README.md)

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
