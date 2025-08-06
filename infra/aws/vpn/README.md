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
