############################################
# SECRETS MODULE
# Generates a strong DB password and stores
# credentials in AWS Secrets Manager instead
# of plaintext in tfvars/state-adjacent files.
############################################

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!#$%^&*()-_=+"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/db-credentials"
  recovery_window_in_days = 0 # allows immediate re-create while iterating; raise this in real prod

  tags = {
    Name = "${var.project_name}-db-credentials"
  }
}
