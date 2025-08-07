# Migration from EKS to AWS Fargate

This directory contains Terraform code to deploy the Ping-Pong application from Kubernetes (EKS) to AWS Fargate using Amazon ECS. 

## Overview

### Benefits of Migration to Fargate

- **Serverless**: No EKS clusters to manage

### Cons of Migration 
- **Vendor Lock-in**: Migrating to Fargate ties the application more closely to AWS services, making it harder to switch cloud providers in the future.
- **Kubernetes resources vs Task Definitions**: Migration from K8s resources to ECS task definitions requires reconfiguration and shift the problem without simplifying it.
- **IaC vs Helm**: For Fargate, infrastructure as code is needed to deploy the applications, while Helm is used for Kubernetes resources. This requires a shift in mindset and tooling.
- **Less observability**: Fargate provides less visibility into the underlying infrastructure compared to EKS with Container Insights.
- **Cold Start Latency**: Fargate may introduce latency during task startup, any change requires new EC2 instances to be provisioned.
- **Limited Customization**: Less control over the underlying infrastructure
- **Potentially Higher Costs**: For certain workloads, Fargate may be more expensive than EC2


### Application Components

The Ping-Pong application being migrated includes:
- Flask web application with health endpoints
- Container image hosted on GitHub Container Registry (GHCR)
- Load balancer for external access
- Auto-scaling capabilities
- CloudWatch logging and monitoring

## Architecture

### Network Architecture

The Terraform code creates a simplified, cost-effective architecture using public subnets:

```
Internet
    |
    v
Internet Gateway
    |
    v
Public Subnets (ALB + Fargate)
    |
    v
Application Load Balancer
    |
    v
ECS Service (Fargate Tasks)
    |
    v
CloudWatch Logs
```

### Key Components

1. **VPC Configuration**: Flexible VPC selection (default or custom VPC)
2. **Public Subnet Creation**: Automatic creation of public subnets across multiple AZs
3. **Internet Gateway**: Provides internet access for public subnets
4. **Route Tables**: Manages traffic routing for public subnets
5. **Security Groups**: Network security for ALB and Fargate tasks
6. **Application Load Balancer (ALB)**: Distributes incoming traffic across Fargate tasks
7. **ECS Cluster**: Logical grouping of tasks or services
8. **ECS Service**: Manages the desired number of running tasks
9. **ECS Task Definition**: Blueprint for your application containers
10. **Fargate Tasks**: Running instances of your containers in public subnets
11. **Auto Scaling**: Automatically adjusts the number of tasks based on metrics
12. **CloudWatch Logs**: Centralized logging for application monitoring


## Migration Process

### view Current Kubernetes Deployment
   - Analyze the existing Helm charts in `/app/helm-charts/ping-pong/`
   - Note resource requirements (CPU, memory)
   - Document current scaling configurations
   - Review ingress and service configurations
   - 

### Resource Mapping

| Kubernetes Resource | Fargate Equivalent | Notes |
|--------------------|--------------------|-------|
| Deployment | ECS Service + Task Definition | Manages container instances |
| Pod | ECS Task | Individual container instances |
| Service | Application Load Balancer + Target Group | Load balancing and service discovery |
| Ingress | ALB Listener Rules | External access configuration |
| HPA | Application Auto Scaling | CPU/Memory based scaling |
| ConfigMap/Secret | Environment Variables | Configuration management |

### Task Resource Configuration

Fargate has specific CPU and memory combinations. Valid combinations include:

| CPU (vCPU) | Memory (GB) |
|------------|-------------|
| 0.25 | 0.5, 1, 2 |
| 0.5 | 1, 2, 3, 4 |
| 1 | 2, 3, 4, 5, 6, 7, 8 |
| 2 | 4-16 (1GB increments) |
| 4 | 8-30 (1GB increments) |



### CloudWatch Metrics

Key metrics to monitor:
- **CPUUtilization**: Average CPU usage across tasks
- **MemoryUtilization**: Average memory usage across tasks
- **TaskCount**: Number of running tasks
- **ALB Metrics**: Request count, latency, error rates

### Cost Comparison

Example cost comparison for a small application:

| Resource | EKS (t3.small) | Fargate (0.25 vCPU, 0.5GB) |
|----------|---------------|--------------------------|
| Monthly Cost | ~$15-20 | ~$8-12 |
| Management Overhead | Medium | Low |
| Scaling Efficiency | Managed | Automatic |
