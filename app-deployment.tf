resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name = "challenge"
    labels = {
      app = "challenge"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "challenge"
      }
    }

    template {
      metadata {
        labels = {
          app = "challenge"
        }
      }

      spec {
        container {
          name  = "challenge"
          image = "leynerbueno/tech-challenge:latest"

          port {
            container_port = 8080
          }

          env {
            name = "SPRING_DATASOURCE_URL"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "SPRING_DATASOURCE_URL"
              }
            }
          }

          env {
            name = "SPRING_DATASOURCE_USERNAME"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "SPRING_DATASOURCE_USERNAME"
              }
            }
          }

          env {
            name = "SPRING_DATASOURCE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "SPRING_DATASOURCE_PASSWORD"
              }
            }
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "1Gi"
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}
