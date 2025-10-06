data "aws_secretsmanager_secret" "db_password_secret" {
  name = "db_pwd"
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password_secret.id
}

data "aws_secretsmanager_secret" "db_username_secret" {
  name = "db_username"
}

data "aws_secretsmanager_secret_version" "db_username" {
  secret_id = data.aws_secretsmanager_secret.db_username_secret.id
}

data "aws_secretsmanager_secret" "email_user_secret" {
  name = "email_user"
}

data "aws_secretsmanager_secret_version" "email_user" {
  secret_id = data.aws_secretsmanager_secret.email_user_secret.id
}

data "aws_secretsmanager_secret" "email_password_secret" {
  name = "email_password"
}

data "aws_secretsmanager_secret_version" "email_password" {
  secret_id = data.aws_secretsmanager_secret.email_password_secret.id
}

data "aws_secretsmanager_secret" "mercado_pago_token_secret" {
  name = "mercado_pago_token"
}

data "aws_secretsmanager_secret_version" "mercado_pago_token" {
  secret_id = data.aws_secretsmanager_secret.mercado_pago_token_secret.id
}