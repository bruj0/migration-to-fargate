output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "load_balancer_url" {
  description = "URL of the application"
  value       = "http://${aws_lb.app.dns_name}"
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.app.zone_id
}

output "vpc_id" {
  description = "ID of the VPC being used"
  value       = local.vpc_id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway being used (existing or newly created)"
  value       = local.internet_gateway_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets created"
  value       = aws_subnet.public[*].id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.app.id
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.app.family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.app.revision
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.app.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.app.arn
}

output "task_execution_role_arn" {
  description = "ARN of the task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the task role"
  value       = aws_iam_role.ecs_task.arn
}

output "security_group_fargate_id" {
  description = "ID of the Fargate security group"
  value       = aws_security_group.fargate_task.id
}

output "security_group_alb_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "autoscaling_target_resource_id" {
  description = "Resource ID of the autoscaling target"
  value       = aws_appautoscaling_target.ecs_target.resource_id
}
