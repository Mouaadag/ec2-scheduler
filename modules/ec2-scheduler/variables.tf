variable "instance_type" {
  description = "The type of EC2 instance to use for the scheduler."
  type        = string
  default     = "t2.micro"
}

variable "desired_capacity" {
  description = "The desired number of EC2 instances."
  type        = number
  default     = 1
}

variable "min_size" {
  description = "The minimum number of EC2 instances."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of EC2 instances."
  type        = number
  default     = 3
}

variable "schedule_expression" {
  description = "The schedule expression for starting and stopping the EC2 instances."
  type        = string
  default     = "cron(0 12 * * ? *)"  # Example: every day at 12:00 UTC
}

variable "key_name" {
  description = "The name of the key pair to use for the EC2 instances."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the EC2 instances will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs where the EC2 instances will be deployed."
  type        = list(string)
}