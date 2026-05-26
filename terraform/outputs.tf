output "vpc_id" {
  description = "Created VPC ID."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Created public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "app_security_group_id" {
  description = "Security group attached to the EC2 deployment host."
  value       = aws_security_group.app.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance."
  value       = aws_instance.app.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance."
  value       = aws_instance.app.public_dns
}

output "api_gateway_url" {
  description = "API Gateway URL exposed by the EC2 instance."
  value       = "http://${aws_instance.app.public_dns}:8080"
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for all services."
  value = {
    for service, repository in aws_ecr_repository.service :
    service => repository.repository_url
  }
}

output "order_events_queue_url" {
  description = "SQS queue URL for order events, when enabled."
  value       = var.enable_sqs ? aws_sqs_queue.order_events[0].url : null
}
