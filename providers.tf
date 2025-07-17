provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Project     = "my-webApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}