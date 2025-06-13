
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
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
resource "aws_route_table_association" "mh-route-table-association" {
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

# 7. ECS Cluster
resource "aws_ecs_cluster" "mh-ecs-cluster" {
  name = "mh-ecs-cluster"
  tags = {
    Name = "mh-ecs-cluster"
  }
}
# 8. ECS Cluster capacity providers
resource "aws_ecs_cluster_capacity_providers" "mh-aws_ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.mh-ecs-cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
# 9. ECS Task Execution Role
resource "aws_iam_role" "mh-ecs-aws-iam-role" {
  name = "mh-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Effect    = "Allow"
    }]
  })
}
# 10. ECS Task Definition
resource "aws_ecs_task_definition" "mh-nginx-app" {
  family                   = "mh-nginx-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.mh-ecs-aws-iam-role.arn

  container_definitions = jsonencode([{
    name      = "app"
    image     = "nginx"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}
# 11. Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "mh-ecs-task-exec-attach" {
  role       = aws_iam_role.mh-ecs-aws-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# 12. ECS Service
resource "aws_ecs_service" "mh-service" {
  name            = "mh-service"
  cluster         = aws_ecs_cluster.mh-ecs-cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.mh-nginx-app.arn
  desired_count   = 1

  network_configuration {
    subnets         = [aws_subnet.mh-subnet-rs.id]
    assign_public_ip = true
    security_groups = [aws_security_group.mh-security-group.id]
  }
}
