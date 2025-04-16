module "network" {
  source = "./infrastructure/network"

  client_id          = var.client_id
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = var.environment
  aws_region         = var.aws_region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "n8n-${var.client_id}-cluster"
  cluster_version = var.eks_version

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids

  enable_irsa = true

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    n8n_nodes = {
      instance_types = [var.node_instance_type]

      min_size     = var.min_nodes
      max_size     = var.max_nodes
      desired_size = var.min_nodes

      labels = {
        Environment = var.environment
        Project     = "n8n"
      }

      tags = {
        Name = "n8n-${var.client_id}-node-group"
      }
    }
  }

  tags = {
    Environment = var.environment
    Project     = "n8n-workflows"
    Terraform   = "true"
  }
}

resource "aws_security_group" "n8n_database" {
  name        = "n8n-database-sg"
  description = "Security group for N8N database"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }
}

resource "aws_db_subnet_group" "n8n" {
  name       = "n8n-${var.client_id}-subnet-group"
  subnet_ids = module.network.private_subnet_ids

  tags = {
    Name = "N8N DB subnet group"
  }
}

resource "aws_kms_key" "db_encryption" {
  description             = "KMS key for N8N database encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "n8n-db-encryption-key"
    Environment = var.environment
  }
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "n8n-${var.client_id}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "n8nuser"
    password = random_password.db_password.result
    host     = aws_db_instance.n8n.endpoint
    port     = aws_db_instance.n8n.port
    dbname   = aws_db_instance.n8n.db_name
  })
}

resource "aws_db_instance" "n8n" {
  identifier           = "n8n-${var.client_id}-db"
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp3"
  
  db_name              = "n8ndb"
  username             = "n8nuser"
  password             = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.n8n.name
  vpc_security_group_ids = [aws_security_group.n8n_database.id]

  backup_retention_period = var.db_backup_retention
  backup_window           = "03:00-05:00"
  maintenance_window      = "Mon:05:00-Mon:07:00"

  storage_encrypted = true
  kms_key_id        = aws_kms_key.db_encryption.arn

  deletion_protection = var.environment == "prod"

  tags = {
    Name        = "n8n-${var.client_id}-database"
    Environment = var.environment
  }
}
