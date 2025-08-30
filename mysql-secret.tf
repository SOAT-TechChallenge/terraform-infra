resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }

  data = {
    MYSQL_ROOT_PASSWORD         = "cm9vdDEyMw=="
    SPRING_DATASOURCE_PASSWORD   = "cm9vdDEyMw=="
    SPRING_DATASOURCE_URL      = "jdbc:mysql://terraform-20240930234115520800000001.cpuy8crp9yqu.us-east-1.rds.amazonaws.com:3306/fiap"
    SPRING_DATASOURCE_USERNAME  = "cm9vdA=="
    EMAIL_USER  = "dGVjaGNoYWxsZW5nZS5ub3JlcGx5QGdtYWlsLmNvbQ=="
    EMAIL_PASS  = "c2JqbXJkZmR1d2tqYXFobg=="
  }
}