# 1. Internet Gateway
resource "aws_internet_gateway" "mh-internet-gateway-rs" {
  vpc_id = var.resource.vpc_id
  tags = {
    Name = "${var.resource.tag}-internet-gateway"
  }
}
# 2. Route Table
resource "aws_route_table" "mh-internet-route-table-rs" {
  vpc_id = var.resource.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mh-internet-gateway-rs.id
  }
  tags = {
    Name = "${var.resource.tag}-route-table"
  }
}

# 3. Associate Route Table with Subnet
resource "aws_route_table_association" "mh-route-table-association" {
  subnet_id      = var.resource.subnet_id
  route_table_id = aws_route_table.mh-internet-route-table-rs.id
}

# 4. Security Group
resource "aws_security_group" "mh-security-group" {
  name        = "${var.resource.tag}-security-group"
  description = "Allow SSH"
  vpc_id      = var.resource.vpc_id

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

# 5. ECS Cluster
resource "aws_ecs_cluster" "mh-ecs-cluster" {
  name = "${var.resource.tag}-ecs-cluster"
  tags = {
    Name = "${var.resource.tag}-ecs-cluster"
  }
}
# 6. ECS Cluster capacity providers
resource "aws_ecs_cluster_capacity_providers" "mh-aws_ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.mh-ecs-cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
# 7. ECS Task Execution Role
resource "aws_iam_role" "mh-ecs-aws-iam-role" {
  name = "${var.resource.tag}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Effect    = "Allow"
    }]
  })
}
# 8. ECS Task Definition
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

# 9. Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "mh-ecs-task-exec-attach" {
  role       = aws_iam_role.mh-ecs-aws-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 10. ECS Service
resource "aws_ecs_service" "mh-service" {
  name            = "${var.resource.tag}-service"
  cluster         = aws_ecs_cluster.mh-ecs-cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.mh-nginx-app.arn
  desired_count   = 1

  network_configuration {
    subnets         = [var.resource.subnet_id]
    assign_public_ip = true
    security_groups = [aws_security_group.mh-security-group.id]
  }
}