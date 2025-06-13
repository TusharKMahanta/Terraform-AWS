1. **Provider**
  - **Description**: Configures the AWS provider to interact with AWS resources.
  - **Details**:
    - Region: `ap-south-1`

2. **VPC**
  - **Description**: Creates a Virtual Private Cloud to logically isolate AWS resources.
  - **Details**:
    - CIDR Block: `10.0.0.0/16`
    - Name: `mh-vpc-rs`

3. **Subnet**
  - **Description**: Provisions a subnet within the VPC to host resources like ECS tasks.
  - **Details**:
    - CIDR Block: `10.0.0.0/24`
    - Name: `mh-subnet-rs`

4. **Internet Gateway**
  - **Description**: Attaches an Internet Gateway to the VPC for outbound internet access.
  - **Details**:
    - Name: `mh-internet-gateway-rs`

5. **Route Table**
  - **Description**: Sets up a route table to manage routing within the VPC.
  - **Details**:
    - Default Route: `0.0.0.0/0` via Internet Gateway
    - Name: `mh-internet-route-table-rs`

6. **Route Table Association**
  - **Description**: Associates the subnet with the route table for internet connectivity.
  - **Details**:
    - Subnet: `mh-subnet-rs`
    - Route Table: `mh-internet-route-table-rs`

7. **Security Group**
  - **Description**: Defines firewall rules for resources in the subnet.
  - **Details**:
    - Inbound: SSH (port 22) from anywhere
    - Outbound: All traffic allowed
    - Name: `mh-security-group`

8. **ECS Cluster**
  - **Description**: Creates an ECS cluster to run containerized applications.
  - **Details**:
    - Name: `mh-ecs-cluster`

9. **ECS Cluster Capacity Providers**
  - **Description**: Configures the ECS cluster to use Fargate as the capacity provider.
  - **Details**:
    - Capacity Provider: `FARGATE`

10. **IAM Role for ECS Task Execution**
   - **Description**: IAM role allowing ECS tasks to interact with AWS services.
   - **Details**:
    - Trust Relationship: `ecs-tasks.amazonaws.com`
    - Name: `mh-ecs-aws-iam-role`

11. **IAM Role Policy Attachment**
   - **Description**: Attaches the AmazonECSTaskExecutionRolePolicy to the ECS task execution role.
   - **Details**:
    - Policy: `AmazonECSTaskExecutionRolePolicy`
    - Role: `mh-ecs-aws-iam-role`

12. **ECS Task Definition**
   - **Description**: Defines a Fargate-compatible ECS task running an NGINX container.
   - **Details**:
    - Container: `nginx`
    - Port: `80`
    - Name: `mh-nginx-app`

13. **ECS Service**
   - **Description**: Deploys the ECS task as a service in the cluster.
   - **Details**:
    - Cluster: `mh-ecs-cluster`
    - Subnet: `mh-subnet-rs`
    - Security Group: `mh-security-group`
    - Assigns Public IP: Yes
    - Name: `mh-service`
