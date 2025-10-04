terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }

  backend "s3" {
    bucket = "techchallenge-tf-state-tch"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
