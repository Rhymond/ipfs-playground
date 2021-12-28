variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "aws_cloudwatch_retention_in_days" {
  type        = number
  description = "AWS CloudWatch Logs Retention in Days"
  default     = 1
}

variable "app_name" {
  type        = string
  description = "Application Name"
}

variable "cidr" {
  description = "The CIDR block for the VPC."
}

variable "public_subnet" {
  description = "List of public subnets"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
