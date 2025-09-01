resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name = "mysql-secret"
  }

  data = {
    MYSQL_ROOT_PASSWORD        = "root12345" 
    SPRING_DATASOURCE_PASSWORD = "root12345" 
    SPRING_DATASOURCE_URL      = "jdbc:mysql://tech-challenge-db.cbia2wmkcvfh.us-east-1.rds.amazonaws.com:3306/fiap"
    SPRING_DATASOURCE_USERNAME = "admin"     
    EMAIL_USER                 = "techchallenge.noreply@gmail.com"  
    EMAIL_PASS                 = "sbjmrdfduwjdaqhn"  
  }
  
  depends_on = [aws_db_instance.mysql_database]
}