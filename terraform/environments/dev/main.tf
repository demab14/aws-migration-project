terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
  admin_cidr   = var.admin_cidr
}

module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  bucket_name  = var.migration_bucket_name
}

module "secrets" {
  source = "../../modules/secrets"

  project_name = var.project_name
}

module "iam" {
  source = "../../modules/iam"

  project_name  = var.project_name
  bucket_arn    = module.s3.bucket_arn
  db_secret_arn = module.secrets.secret_arn
}

module "rds" {
  source = "../../modules/rds"

  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id
  db_username        = var.db_username
  db_password        = module.secrets.db_password
}

# Once RDS exists we know the endpoint, so this is the version of the
# secret that Ansible/EC2 will actually read at deploy time — it carries
# username, password, host, port and db name together.
resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = module.secrets.secret_id
  secret_string = jsonencode({
    username = var.db_username
    password = module.secrets.db_password
    host     = module.rds.db_endpoint
    port     = module.rds.db_port
    dbname   = module.rds.db_name
  })
}

module "ec2" {
  source = "../../modules/ec2"

  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  public_subnet_id       = module.vpc.public_subnet_ids[0]
  public_subnet_ids      = module.vpc.public_subnet_ids
  ec2_sg_id               = module.security_groups.ec2_sg_id
  alb_sg_id               = module.security_groups.alb_sg_id
  key_name                = var.key_name
  instance_profile_name   = module.iam.instance_profile_name
}
