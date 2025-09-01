resource "kubernetes_service" "app_service" {
  metadata {
    name = "challenge-service"
  }

  spec {
    selector = {
      app = "challenge"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"  # Mudei para LoadBalancer para ter IP público
  }

  depends_on = [kubernetes_deployment.app_deployment]
}