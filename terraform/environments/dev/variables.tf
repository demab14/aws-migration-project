variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "project_name" {
  type    = string
  default = "wp-migration"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "admin_cidr" {
  description = "Your IP in CIDR form, e.g. 203.0.113.4/32 — never leave this as 0.0.0.0/0"
  type        = string
}

variable "migration_bucket_name" {
  description = "Globally unique S3 bucket name used for the MySQL dump transfer"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair"
  type        = string
}

variable "db_username" {
  type    = string
  default = "wpadmin"
}

# No db_password variable anymore — the secrets module generates a random
# password and stores it (along with the RDS endpoint) in Secrets Manager.

