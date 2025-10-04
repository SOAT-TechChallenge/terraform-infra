resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  vpc_config {
    subnet_ids = data.aws_subnets.private.ids
  }

  tags = {
    Terraform = "true"
    Project   = "techchallenge"
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-nodegroup"
  node_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  subnet_ids      = data.aws_subnets.private.ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  tags = {
    Terraform = "true"
    Project   = "techchallenge"
  }
}

# Security Group Rule para permitir tráfego do EKS para o RDS
resource "aws_security_group_rule" "eks_to_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = var.rds_security_group_id
  description              = "Allow outbound MySQL to RDS"
}

resource "aws_security_group_rule" "rds_to_eks" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = var.rds_security_group_id
  source_security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  description              = "Allow MySQL from EKS"
}
