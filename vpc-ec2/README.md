# Terraform AWS VPC Setup

This document outlines the Terraform configuration for setting up an AWS  and EC2 with associated resources.

## Resources Created

1. **VPC**
   - **Description**: Creates a Virtual Private Cloud (VPC) to isolate resources in a logically separated network.
   - **Details**:
     - CIDR Block: `10.0.0.0/16`
     - Name: `mh-vpc`

2. **Subnet**
   - **Description**: Creates a subnet within the VPC to host resources like EC2 instances.
   - **Details**:
     - CIDR Block: `10.0.0.0/24`
     - Name: `mh-subnet`

3. **Internet Gateway**
   - **Description**: Provides internet access to resources within the VPC.
   - **Details**:
     - Name: `mh-internet-gateway`

4. **Route Table**
   - **Description**: Defines routing rules for the VPC.
   - **Details**:
     - Routes:
       - Destination: `0.0.0.0/0`
       - Gateway: Internet Gateway
     - Name: `mh-route-table`

5. **Route Table Association**
   - **Description**: Associates the route table with the subnet to apply routing rules.
   - **Details**:
     - Subnet: `mh-subnet`
     - Route Table: `mh-route-table`

6. **Security Group**
   - **Description**: Controls inbound and outbound traffic for resources in the VPC.
   - **Details**:
     - Name: `mh-security-group`
     - Ingress Rule:
       - Protocol: `tcp`
       - Port: `22`
       - CIDR: `0.0.0.0/0`
     - Egress Rule:
       - Protocol: `-1`
       - Port: `All`
       - CIDR: `0.0.0.0/0`

7. **EC2 Instance**
   - **Description**: Launches a virtual machine in the VPC.
   - **Details**:
     - AMI: `ami-0e35ddab05955cf57` (Amazon Linux 2)
     - Instance Type: `t2.micro`
     - Subnet: `mh-subnet`
     - Security Group: `mh-security-group`
     - Key Pair: `tushar`
     - Name: `mh-ec2-instance`

## Notes

- Ensure the AMI ID is updated based on the region.
- Replace the key pair name (`tushar`) with your actual key pair name.