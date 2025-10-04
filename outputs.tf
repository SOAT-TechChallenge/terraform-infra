output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security Group ID do cluster EKS"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "app_service_name" {
  description = "Nome do Service da aplicação"
  value       = kubernetes_service.app_service.metadata[0].name
}

output "ingress_name" {
  description = "Nome do Ingress"
  value       = kubernetes_ingress_v1.app_ingress.metadata[0].name
}
