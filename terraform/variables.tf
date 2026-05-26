variable "aws_region" {
  description = "AWS region where the infrastructure will be created."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name used to prefix AWS resources."
  type        = string
  default     = "microservices-lab"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to connect through SSH."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_cidr_blocks" {
  description = "CIDR blocks allowed to access the application ports."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type used to host the microservices."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name for SSH access."
  type        = string
  default     = ""
}

variable "container_image_tag" {
  description = "Default container image tag used by deployment pipelines."
  type        = string
  default     = "latest"
}

variable "enable_sqs" {
  description = "Whether to create SQS resources for event-driven activities."
  type        = bool
  default     = true
}
