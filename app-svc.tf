resource "kubernetes_service" "app_service" {
  metadata {
    name = "challenge"
  }

  spec {
    selector = {
      app = kubernetes_deployment.app_deployment.metadata[0].labels["app"] 
    }

    port {
      port       = 8080
      node_port  = 30005
    }

    type = "NodePort"
  }
}
