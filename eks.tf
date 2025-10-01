resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/c173096a4485959l11162310t1w587930-LabEksClusterRole-EknFOPxAwF4B"

  vpc_config {
    subnet_ids = [
      data.aws_subnet.eks_subnet_private_1.id,
      data.aws_subnet.eks_subnet_private_2.id
    ]
  }

  tags = {
    Terraform = "true"
  }
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-nodegroup"
  node_role_arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/c173096a4485959l11162310t1w587930199-LabEksNodeRole-mI1H32GtG3fp"
  subnet_ids = [
    data.aws_subnet.eks_subnet_private_1.id,
    data.aws_subnet.eks_subnet_private_2.id
  ]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  capacity_type  = "ON_DEMAND"

  tags = {
    Terraform = "true"
  }
}

resource "aws_security_group_rule" "eks_nodes_to_rds" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = data.aws_security_group.rds_sg.id
  description              = "Allow outbound MySQL to RDS"
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "nodegroup_name" {
  description = "Name of the security group for the EKS node group"
  value       = aws_eks_node_group.node_group.node_group_name
}

output "nodegroup_sg_id" {
  description = "ID of the security group for the EKS node group"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}
