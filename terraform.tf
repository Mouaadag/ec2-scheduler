terraform {
  # Backend configuration pour Terraform Cloud
  cloud {
    organization = "my-webApp"  # 
    
    workspaces {
      name = "my-webApp-dev"  # défaut
    }
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"
}
