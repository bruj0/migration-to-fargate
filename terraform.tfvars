# AWS Configuration
aws_region = "eu-north-1"

# Network Configuration
vpc_id = "vpc-062e6dccd246f4b4e"
availability_zones = ["eu-north-1a", "eu-north-1b"]  # Leave empty to use all available AZs

# Custom CIDR blocks for public subnets (adjusted to fit VPC 10.0.0.0/16)
public_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# Application Configuration
app_name     = "ping-pong"
environment  = "dev"

# Container Configuration
container_image = "ghcr.io/bruj0/cicd-for-eks/ping-pong:latest"
container_port  = 5000

# Fargate Task Configuration
task_cpu    = "256"  # 256 (.25 vCPU), 512 (.5 vCPU), 1024 (1 vCPU), 2048 (2 vCPU), 4096 (4 vCPU)
task_memory = "512"  # Memory in MB, must be compatible with CPU value

# Service Configuration
desired_count = 1
min_capacity  = 1
max_capacity  = 2

# Capacity Provider
capacity_provider = "FARGATE"  # Options: FARGATE, FARGATE_SPOT

# Auto Scaling Configuration
enable_auto_scaling = true
cpu_threshold       = 70
memory_threshold    = 80

# Health Check Configuration
health_check_grace_period = 300

# Additional Tags
tags = {
  Project     = "cicd-for-eks"
  Owner       = "DevOps Team"
  Cost-Center = "Engineering"
}
