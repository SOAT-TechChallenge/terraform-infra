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

          env {
            name = "EMAIL_USER"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "EMAIL_USER"
              }
            }
          }

          env {
            name = "EMAIL_PASS"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "EMAIL_PASS"
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

          # REMOVA TODAS AS PROBES TEMPORARIAMENTE - COMENTE ESTAS LINHAS
          # liveness_probe {
          #   http_get {
          #     path = "/actuator/health"
          #     port = 8080
          #   }
          #   initial_delay_seconds = 40
          #   period_seconds        = 10
          #   failure_threshold     = 3
          #   timeout_seconds       = 5
          # }

          # readiness_probe {
          #   http_get {
          #     path = "/actuator/health"
          #     port = 8080
          #   }
          #   initial_delay_seconds = 45
          #   period_seconds        = 5
          #   failure_threshold     = 3
          #   timeout_seconds       = 5
          # }

          # startup_probe {
          #   http_get {
          #     path = "/actuator/health"
          #     port = 8080
          #   }
          #   initial_delay_seconds = 10
          #   period_seconds        = 10
          #   failure_threshold     = 12
          #   timeout_seconds       = 1
          # }
        }
      }
    }
  }

  depends_on = [
    kubernetes_secret.mysql_secret,
    aws_db_instance.mysql_database,
    aws_eks_cluster.eks_cluster
  ]
}