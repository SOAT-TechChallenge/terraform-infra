provider "aws" {
  region = "us-east-1"
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

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks_auth.token

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.eks_cluster.name]
      command     = "aws"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "existing_vpc" {
  id = "vpc-07f3bea16806e2aad"
}

data "aws_subnet" "eks_subnet_public_1" {
  id = "subnet-0b2ed798ab8be3725"
}

data "aws_subnet" "eks_subnet_public_2" {
  id = "subnet-0425ed75b4f68c878"
}

data "aws_subnet" "eks_subnet_private_1" {
  id = "subnet-0d5ef8199668c0723"
}

data "aws_subnet" "eks_subnet_private_2" {
  id = "subnet-0fdeb0eec779b86f9"
}

data "aws_security_group" "rds_sg" {
  id = "sg-082941b24bbd2866e"
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "techchallenge-cluster"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }

  required_version = "~> 1.0"
}
