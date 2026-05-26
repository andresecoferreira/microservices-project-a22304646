# Terraform Infrastructure

This folder contains simple AWS infrastructure for the lab CI/CD activities.

## What It Creates

- VPC with public subnets, internet gateway and route table
- Security group for SSH and Spring Boot ports `8080` to `8083`
- EC2 instance with Docker installed
- ECR repositories for:
  - `api-gateway`
  - `user-service`
  - `product-service`
  - `order-service`
- SQS queue and dead-letter queue for the event-driven activity

## Usage

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Set `ssh_cidr_blocks` to your own public IP before applying in a real AWS account.

## Useful Outputs

After `terraform apply`, Terraform prints:

- `api_gateway_url`: public URL for the API Gateway
- `ec2_public_ip`: IP address for SSH/deployment
- `ecr_repository_urls`: container repositories used by GitHub Actions
- `order_events_queue_url`: SQS URL for the Week 11 activity
