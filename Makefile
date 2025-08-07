# Makefile for Fargate deployment

.PHONY: help init plan apply destroy validate fmt check clean status logs

# Default environment
ENV ?= dev

# Help target
help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Initialize Terraform
init: ## Initialize Terraform
	terraform init

# Validate Terraform configuration
validate: ## Validate Terraform configuration
	terraform validate

# Format Terraform files
fmt: ## Format Terraform files
	terraform fmt -recursive

# Plan deployment
plan: ## Plan Terraform deployment
	terraform plan -var="environment=$(ENV)"

# Apply deployment
apply: ## Apply Terraform deployment
	terraform apply -var="environment=$(ENV)" -auto-approve

# Plan destroy
plan-destroy: ## Plan Terraform destroy
	terraform plan -destroy -var="environment=$(ENV)"

# Destroy infrastructure
destroy: ## Destroy Terraform infrastructure
	terraform destroy -var="environment=$(ENV)" -auto-approve

# Check infrastructure status
status: ## Check ECS service status
	@echo "=== ECS Cluster Status ==="
	aws ecs describe-clusters --clusters ping-pong-cluster --query 'clusters[0].[clusterName,status,runningTasksCount,activeServicesCount]' --output table
	@echo ""
	@echo "=== ECS Service Status ==="
	aws ecs describe-services --cluster ping-pong-cluster --services ping-pong --query 'services[0].[serviceName,status,runningCount,desiredCount]' --output table
	@echo ""
	@echo "=== ALB Status ==="
	aws elbv2 describe-load-balancers --names ping-pong-alb --query 'LoadBalancers[0].[LoadBalancerName,State.Code,DNSName]' --output table

# View application logs
logs: ## View application logs (last 10 minutes)
	aws logs tail "/ecs/ping-pong" --since 10m

# Follow application logs
logs-follow: ## Follow application logs in real-time
	aws logs tail "/ecs/ping-pong" --follow

# Get application URL
url: ## Get application URL
	@terraform output -raw load_balancer_url 2>/dev/null || echo "Run 'make apply' first to get the URL"

# Test application endpoints
test: ## Test application endpoints
	@URL=$$(terraform output -raw load_balancer_url 2>/dev/null); \
	if [ -n "$$URL" ]; then \
		echo "Testing application endpoints..."; \
		echo "=== Health Check ==="; \
		curl -s "$$URL/health" | jq .; \
		echo ""; \
		echo "=== Ping Endpoint ==="; \
		curl -s "$$URL/ping"; \
		echo ""; \
		echo "=== Hello Endpoint ==="; \
		curl -s -X POST "$$URL/hello" -H "Content-Type: application/json" -d '{"name":"Fargate"}' | jq .; \
	else \
		echo "Application not deployed. Run 'make apply' first."; \
	fi

# Complete check - validate, format, and plan
check: fmt validate plan ## Run format, validate, and plan

# Clean up temporary files
clean: ## Clean up temporary files
	rm -f *.tfplan
	rm -f terraform.tfstate.backup

# Scale service up
scale-up: ## Scale service to 4 tasks
	aws ecs update-service --cluster ping-pong-cluster --service ping-pong --desired-count 4

# Scale service down
scale-down: ## Scale service to 1 task
	aws ecs update-service --cluster ping-pong-cluster --service ping-pong --desired-count 1

# Get service metrics
metrics: ## Get CloudWatch metrics for the service
	@echo "=== CPU Utilization (last 1 hour) ==="
	aws cloudwatch get-metric-statistics \
		--namespace AWS/ECS \
		--metric-name CPUUtilization \
		--dimensions Name=ServiceName,Value=ping-pong Name=ClusterName,Value=ping-pong-cluster \
		--start-time $$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
		--end-time $$(date -u +%Y-%m-%dT%H:%M:%S) \
		--period 300 \
		--statistics Average \
		--query 'Datapoints[*].[Timestamp,Average]' \
		--output table
	@echo ""
	@echo "=== Memory Utilization (last 1 hour) ==="
	aws cloudwatch get-metric-statistics \
		--namespace AWS/ECS \
		--metric-name MemoryUtilization \
		--dimensions Name=ServiceName,Value=ping-pong Name=ClusterName,Value=ping-pong-cluster \
		--start-time $$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
		--end-time $$(date -u +%Y-%m-%dT%H:%M:%S) \
		--period 300 \
		--statistics Average \
		--query 'Datapoints[*].[Timestamp,Average]' \
		--output table

# Development workflow
dev: check apply test ## Complete development workflow: check, apply, and test

# Production deployment workflow  
prod: ## Production deployment workflow with confirmation
	@echo "WARNING: This will deploy to production!"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ]
	$(MAKE) ENV=prod check
	$(MAKE) ENV=prod apply
	$(MAKE) test

# Create terraform.tfvars from example
setup: ## Create terraform.tfvars from example
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "Created terraform.tfvars from example. Please edit it with your specific values."; \
	else \
		echo "terraform.tfvars already exists."; \
	fi

# Show all outputs
outputs: ## Show all Terraform outputs
	terraform output

# Emergency stop - scale to 0
emergency-stop: ## Emergency stop - scale service to 0 tasks
	@echo "WARNING: This will stop all application tasks!"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ]
	aws ecs update-service --cluster ping-pong-cluster --service ping-pong --desired-count 0
