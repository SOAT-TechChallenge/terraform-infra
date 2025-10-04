resource "aws_cognito_user_pool" "techchallenge_user_pool" {
  name              = "techchallenge-user-pool"
  region            = "us-east-1"
  mfa_configuration = "OFF"

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  schema {
    attribute_data_type = "String"
    name                = "user_type"
    required            = false
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 20
    }
  }

  schema {
    attribute_data_type = "String"
    name                = "cpf"
    required            = false
    mutable             = true

    string_attribute_constraints {
      min_length = 11
      max_length = 11
    }
  }

  password_policy {
    minimum_length    = 8
    require_uppercase = false
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
  }
}

resource "aws_cognito_user_pool_client" "techchallenge_client" {
  name         = "techchallenge-client"
  user_pool_id = aws_cognito_user_pool.techchallenge_user_pool.id
  region       = var.aws_region

  generate_secret               = false
  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity  = 24
  id_token_validity      = 24
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  read_attributes = [
    "name",
    "custom:user_type",
  ]

  write_attributes = [
    "custom:user_type"
  ]
}

output "user_pool_id" {
  description = "ID do Cognito User Pool"
  value       = aws_cognito_user_pool.techchallenge_user_pool.id
}

output "user_pool_client_id" {
  description = "ID do App Client"
  value       = aws_cognito_user_pool_client.techchallenge_client.id
}

output "user_pool_endpoint" {
  description = "Endpoint do User Pool"
  value       = aws_cognito_user_pool.techchallenge_user_pool.endpoint
}

output "jwks_uri" {
  description = "URL das chaves públicas para validar JWT"
  value       = "https://${aws_cognito_user_pool.techchallenge_user_pool.endpoint}/.well-known/jwks.json"
}
