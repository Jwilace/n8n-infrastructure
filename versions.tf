terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  backend "s3" {
    bucket         = "n8n-terraform-state-jwilace"
    key            = "n8n/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "n8n-terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
