terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# 1. Create a VPC
resource "aws_vpc" "mh-vpc-rs" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "mh-vpc"
  }
}

# 2. Create Subnet
resource "aws_subnet" "mh-subnet-rs" {
  vpc_id     = aws_vpc.mh-vpc-rs.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "mh-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "mh-internet-gateway-rs" {
  vpc_id = aws_vpc.mh-vpc-rs.id
  tags = {
    Name = "mh-internet-gateway"
  }
}

# 4. Route Table
resource "aws_route_table" "mh-internet-route-table-rs" {
  vpc_id = aws_vpc.mh-vpc-rs.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mh-internet-gateway-rs.id
  }
  tags = {
    Name = "mh-route-table"
  }
}

# 5. Associate Route Table with Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mh-subnet-rs.id
  route_table_id = aws_route_table.mh-internet-route-table-rs.id
}

# 6. Security Group
resource "aws_security_group" "mh-security-group" {
  name        = "mh-security-group"
  description = "Allow SSH"
  vpc_id      = aws_vpc.mh-vpc-rs.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. EC2 Instance
resource "aws_instance" "mh_ec2" {
  ami           = "ami-0e35ddab05955cf57" # Amazon Linux 2 (update based on region)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mh-subnet-rs.id
  vpc_security_group_ids = [aws_security_group.mh-security-group.id]
  key_name      = "tushar" # Replace with your actual key pair name

  tags = {
    Name = "mh-ec2-instance"
  }
}