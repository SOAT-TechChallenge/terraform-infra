provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
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

resource "aws_iam_role" "eks_role" {
  name = "eks_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_cni_policy" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy" "eks_k8s_access" {
  name   = "EKS_K8S_Access"
  role   = aws_iam_role.eks_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "challenge"
  role_arn = aws_iam_role.eks_role.arn

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
  node_role_arn   = aws_iam_role.worker_role.arn
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
}
