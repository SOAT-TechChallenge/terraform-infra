# Usar a VPC existente do RDS
data "aws_vpc" "shared" {
  filter {
    name   = "tag:Name"
    values = ["techchallenge-vpc"]
  }
}

# Obter subnets privadas existentes
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

# Obter subnets públicas existentes
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

output "vpc_id" {
  description = "ID da VPC compartilhada"
  value       = data.aws_vpc.shared.id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = data.aws_subnets.private.ids
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = data.aws_subnets.public.ids
}