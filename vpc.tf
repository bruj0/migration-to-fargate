# VPC and Networking Resources

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Configuration - use provided VPC or default VPC
data "aws_vpc" "selected" {
  id      = var.vpc_id != "" ? var.vpc_id : null
  default = var.vpc_id == "" ? true : null
}

locals {
  vpc_id = data.aws_vpc.selected.id
  
  # Determine AZs to use
  azs_to_use = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 3)
}

# Check for existing Internet Gateway
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [local.vpc_id]
  }
}

# Internet Gateway - use existing if available, create new if needed
resource "aws_internet_gateway" "main" {
  count  = length(data.aws_internet_gateway.existing.id) > 0 ? 0 : 1
  vpc_id = local.vpc_id

  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.environment
    Application = var.app_name
  }
}

locals {
  internet_gateway_id = length(data.aws_internet_gateway.existing.id) > 0 ? data.aws_internet_gateway.existing.id : aws_internet_gateway.main[0].id
}

# Public Subnets (for ALB and Fargate tasks)
resource "aws_subnet" "public" {
  count = length(local.azs_to_use)
  
  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.azs_to_use[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Application = var.app_name
    Type        = "Public"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.internet_gateway_id
  }

  tags = {
    Name        = "${var.app_name}-public-rt"
    Environment = var.environment
    Application = var.app_name
  }
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "fargate_task" {
  name_prefix = "${var.app_name}-fargate-"
  vpc_id      = local.vpc_id
  description = "Security group for Fargate tasks"

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic on container port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.app_name}-fargate-sg"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.app_name}-alb-"
  vpc_id      = local.vpc_id
  description = "Security group for Application Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.app_name}-alb-sg"
    Environment = var.environment
    Application = var.app_name
  }
}
