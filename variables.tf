variable "instance_type" {
  description = "The type of EC2 instance to use for the scheduler"
  type        = string
  default     = "t2.micro"
}

variable "schedule" {
  description = "The schedule for starting and stopping the EC2 instances, in cron format"
  type        = string
  default     = "cron(0 6 ? * MON-FRI *)"
}

variable "region" {
  description = "The AWS region where the EC2 instance is located"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name tag of the EC2 instance to start/stop"
  type        = string
  default     = "my-webApp-Server"
}

variable "environment" {
  description = "Environment name (dev, test, release)"
  type        = string
  default     = "dev"
}

variable "schedule_timezone" {
  description = "Timezone for scheduling (default: Europe/Paris)"
  type        = string
  default     = "Europe/Paris"
}

variable "start_time" {
  description = "Start time in 24h format (HH:MM)"
  type        = string
  default     = "08:00"
}

variable "stop_time" {
  description = "Stop time in 24h format (HH:MM)"  
  type        = string
  default     = "22:00"
}