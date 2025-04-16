### Variables

Create a `terraform.tfvars` file with the following structure:

```hcl
client_id        = "your-client-id"
aws_account_id   = "123456789012"
environment      = "prod"  # prod/staging/dev
aws_region       = "us-east-1"

# GitHub Actions OIDC Configuration
# github_actions_role_arn = "arn:aws:iam::123456789012:role/GithubActionsDeployRole"

# Optional overrides
# vpc_cidr             = "10.0.0.0/16"
# eks_version          = "1.28"
# node_instance_type   = "m5.large"
# min_nodes            = 3
# max_nodes            = 10
```

### GitHub Actions OIDC Authentication

This project supports GitHub Actions OIDC (OpenID Connect) authentication for secure, credential-less AWS deployments:

1. Create an IAM role in AWS with appropriate permissions
2. Configure the GitHub OIDC provider in AWS IAM
3. Set the role ARN in `terraform.tfvars`
4. GitHub Actions will assume this role for deployments

Benefits:
- No long-lived AWS credentials
- Fine-grained access control
- Enhanced security posture
- Automatic credential rotation
