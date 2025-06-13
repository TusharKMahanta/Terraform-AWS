# 1. Create Subnet
resource "aws_subnet" "mh-subnet-rs" {
  vpc_id     = var.resource.vpc_id
  cidr_block = var.resource.cidr_block
  tags = {
    Name = "${var.resource.tag}-subnet"
  }
}