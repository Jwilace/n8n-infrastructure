output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_node_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = module.eks.node_security_group_id
}

output "database_endpoint" {
  description = "Connection endpoint for the database"
  value       = aws_db_instance.n8n.endpoint
  sensitive   = true
}

output "database_port" {
  description = "Port of the database"
  value       = aws_db_instance.n8n.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.n8n.db_name
}

output "database_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.db_credentials.arn
  sensitive   = true
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for database encryption"
  value       = aws_kms_key.db_encryption.arn
  sensitive   = true
}
