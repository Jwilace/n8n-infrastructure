provider "aws" {
  region = var.aws_region

  # OIDC configuration for GitHub Actions
  dynamic "assume_role" {
    for_each = var.github_actions_role_arn != null ? [1] : []
    content {
      role_arn = var.github_actions_role_arn
      session_name = "GitHubActionsDeployment"
    }
  }

  default_tags {
    Project     = "n8n-workflows"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}
