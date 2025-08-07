variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "VPC ID where resources will be created. If not provided, the default VPC will be used"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "List of availability zones to create subnets in. If empty, will use all available AZs"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets. Must have at least 2 for ALB and must be within VPC CIDR range"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "ping-pong"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "container_image" {
  description = "Docker image for the application"
  type        = string
  default     = "ghcr.io/bruj0/cicd-for-eks/ping-pong:latest"
}

variable "container_port" {
  description = "Port on which the container runs"
  type        = number
  default     = 5000
}

variable "task_cpu" {
  description = "CPU units for the Fargate task (1024 = 1 vCPU)"
  type        = string
  default     = "256"
  
  validation {
    condition     = can(regex("^(256|512|1024|2048|4096)$", var.task_cpu))
    error_message = "Task CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "task_memory" {
  description = "Memory for the Fargate task in MB"
  type        = string
  default     = "512"
  
  validation {
    condition = can(regex("^(512|1024|2048|3072|4096|5120|6144|7168|8192|16384|30720)$", var.task_memory))
    error_message = "Task memory must be compatible with the selected CPU value. See AWS Fargate documentation for valid combinations."
  }
}

variable "desired_count" {
  description = "Desired number of tasks running"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 10
}

variable "capacity_provider" {
  description = "Capacity provider for ECS (FARGATE or FARGATE_SPOT)"
  type        = string
  default     = "FARGATE"
  
  validation {
    condition     = can(regex("^(FARGATE|FARGATE_SPOT)$", var.capacity_provider))
    error_message = "Capacity provider must be either FARGATE or FARGATE_SPOT."
  }
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling for the ECS service"
  type        = bool
  default     = true
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for auto scaling"
  type        = number
  default     = 70
}

variable "memory_threshold" {
  description = "Memory utilization threshold for auto scaling"
  type        = number
  default     = 80
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
