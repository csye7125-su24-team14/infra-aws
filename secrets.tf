data "aws_secretsmanager_secret" "docker_config_token" {
  name = "docker_config_token"
}

data "aws_secretsmanager_secret_version" "docker_config_token" {
  secret_id = data.aws_secretsmanager_secret.docker_config_token.id
}
