variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "techchallenge-cluster"
}

variable "db_password" {
  description = "Senha do banco de dados MySQL"
  type        = string
  sensitive   = true
}

variable "rds_endpoint" {
  description = "Endpoint do RDS (vem do outro repositório)"
  type        = string
}

variable "rds_security_group_id" {
  description = "Security Group ID do RDS (vem do outro repositório)"
  type        = string
}
