resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }

  data = {
    MYSQL_ROOT_PASSWORD        = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["db_password"]
    SPRING_DATASOURCE_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["db_password"]
    SPRING_DATASOURCE_URL      = "jdbc:mysql://${data.terraform_remote_state.rds.outputs.rds_endpoint}/fiap"
    SPRING_DATASOURCE_USERNAME = jsondecode(data.aws_secretsmanager_secret_version.db_username.secret_string)["db_username"]
    EMAIL_USER                 = jsondecode(data.aws_secretsmanager_secret_version.email_user.secret_string)["email_user"]
    EMAIL_PASS                 = jsondecode(data.aws_secretsmanager_secret_version.email_password.secret_string)["email_password"]
    MERCADO_PAGO_ACCESS_TOKEN  = jsondecode(data.aws_secretsmanager_secret_version.mercado_pago_token.secret_string)["mercado_pago_token"]
  }

  depends_on = [helm_release.ingress_nginx, aws_eks_cluster.eks_cluster]
}

resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name = "techchallenge"
    labels = {
      app = "techchallenge"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "techchallenge"
      }
    }

    template {
      metadata {
        labels = {
          app = "techchallenge"
        }
      }

      spec {
        container {
          name  = "techchallenge"
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

          env {
            name = "MERCADO_PAGO_ACCESS_TOKEN"
            value_from {
              secret_key_ref {
                name = "mysql-secret"
                key  = "MERCADO_PAGO_ACCESS_TOKEN"
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

  depends_on = [
    kubernetes_secret.mysql_secret,
    helm_release.ingress_nginx,
    aws_eks_cluster.eks_cluster
  ]
}

resource "kubernetes_service" "app_service" {
  metadata {
    name = "techchallenge-service"
  }

  spec {
    selector = {
      app = "techchallenge"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.app_deployment]
}

resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name = "techchallenge-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                        = "nginx"
      "nginx.ingress.kubernetes.io/enable-cors"            = "true"
      "nginx.ingress.kubernetes.io/cors-allow-methods"     = "GET, POST, PUT, DELETE, PATCH, OPTIONS"
      "nginx.ingress.kubernetes.io/cors-allow-origin"      = "*"
      "nginx.ingress.kubernetes.io/cors-allow-credentials" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-headers"     = "Keep-Alive,User-Agent,Cache-Control,Content-Type,Authorization"
      "nginx.ingress.kubernetes.io/cors-max-age"           = "86400"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "hpa" {
  metadata {
    name = "techchallenge-hpa"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "techchallenge"
    }

    min_replicas                      = 1
    max_replicas                      = 10
    target_cpu_utilization_percentage = 50
  }

  depends_on = [kubernetes_deployment.app_deployment]
}
