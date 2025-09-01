provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAVX7DE5UWELBFNWXG"
  secret_key = "KLP5WgMv6a9ejAAD6mkqMvGQqkLwJk1QcyZRelq2"
  token      = "IQoJb3JpZ2luX2VjEK7//////////wEaCXVzLXdlc3QtMiJHMEUCID3oMAhgt9o+JIh675C+VuUBmSjwMKhIVEaUwOt+0nrMAiEAlG4YQLEjqGCzkeab6CLW+d9i+oeHncnKme7AxJHu+GsqswIIFhAAGgwzOTUwNzY0OTY2ODQiDCwwjHKQAJ0djtJFyiqQAoq3SwU549tDtkmrvRnR1sxcmGaouRpM+GBRiS/1VFhEowAMvyK7twk/bVMztnaeEAXjCnHqIcVd+94IVOkNSekZHt10nML+WbWcJVGgoY1J7x735ihMVD4s0Dn+KvPYtwbnQSGpPVs0KqsxformI8nQ417AJulAmZyAvjB/CRaaPFbYWbX1Dw8kb0psZOdlYoKnI0rPZkcM4ZXk9XULBjwV3iQrEXy0euQ98ud2p/w8tWWZHu4q3TA93AosZCxBp6z8TBEoqRXFfqpuT6+JPp2Q662e/PTf3FsB6m5HpIvEK7HVBkOWOUZ6JAOhJzbYu1xFAJ9t6pienpxQ06OU0n+AnMepXd8ZVd78+2OI3CquMOm71sUGOp0BFo23XJB72rDWj7QZX6eSRJm+yy9vDSSIKcFdG8/qgFE3+EFX08BjCJCqVocHlomA+RwcqGvkGwf+/07es2+eoP1zGW6DnYpwuH8jz1hx55ybkXGepIwN/9n7tixTPY1cVHUsUIC0xBEumA7NvFG5ok443tDgVjjIGlLBaVU69Jkoyo5o9x7UlfO/Inr3VR7WkzsYXqKz/FH3Ll2Z+A=="
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
    command     = "aws"
  }
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks_cluster.name
}

# Fetch the existing VPC by ID or tag
data "aws_vpc" "existing_vpc" {
  id = "vpc-0a3cda330a9a42e26"
}

# Fetch existing subnets by their IDs or tags
data "aws_subnet" "eks_subnet_1" {
  id = "subnet-0dbdb383d5ba07a45"
}

data "aws_subnet" "eks_subnet_2" {
  id = "subnet-0544755a56596ec7d"
}

data "aws_subnet" "eks_subnet_3" {
  id = "subnet-07f3f69e4421c1991"
}

# Get current account ID
data "aws_caller_identity" "current" {}

locals {
  eks_role_arn    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "challenge"
  role_arn = local.eks_role_arn

  vpc_config {
    subnet_ids = [
        data.aws_subnet.eks_subnet_1.id, 
        data.aws_subnet.eks_subnet_2.id, 
        data.aws_subnet.eks_subnet_3.id
    ]
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "app-nodes"
  node_role_arn   = local.worker_role_arn
  subnet_ids      = [
        data.aws_subnet.eks_subnet_1.id, 
        data.aws_subnet.eks_subnet_2.id, 
        data.aws_subnet.eks_subnet_3.id
  ]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}

# Recursos do RDS MySQL
resource "aws_db_instance" "mysql_database" {
  identifier           = "tech-challenge-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  max_allocated_storage = 50
  
  db_name              = "fiap"
  username             = "admin"
  password             = "root12345"
  port                 = 3306
  
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  
  backup_retention_period = 3
  skip_final_snapshot     = true
  deletion_protection     = false
  
  tags = {
    Name = "tech-challenge-mysql"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    data.aws_subnet.eks_subnet_1.id,
    data.aws_subnet.eks_subnet_2.id,
    data.aws_subnet.eks_subnet_3.id
  ]
  
  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS MySQL"
  vpc_id      = data.aws_vpc.existing_vpc.id
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [
      data.aws_subnet.eks_subnet_1.cidr_block,
      data.aws_subnet.eks_subnet_2.cidr_block,
      data.aws_subnet.eks_subnet_3.cidr_block
    ]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "rds-mysql-sg"
  }
}

# Output para ver o endpoint do banco
output "database_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = aws_db_instance.mysql_database.endpoint
}

output "database_url" {
  description = "URL JDBC completa para a aplicação"
  value       = "jdbc:mysql://${aws_db_instance.mysql_database.endpoint}/fiap"
}

output "eks_cluster_status" {
  description = "Status do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.status
}

output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.endpoint
}