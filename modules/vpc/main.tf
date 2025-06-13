# 1. Create a VPC
resource "aws_vpc" "mh-vpc-rs" {
  cidr_block = var.resource.cidr_block
  instance_tenancy = var.resource.instance_tenancy
  tags = {
    Name = "${var.resource.tag}-vpc"
  }
}