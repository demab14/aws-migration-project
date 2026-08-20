# Remote state so Terraform state isn't just sitting on one laptop.
# Bucket + DynamoDB table were bootstrapped manually via AWS CLI
# before running `terraform init` with this backend enabled.

terraform {
  backend "s3" {
    bucket         = "wp-migration-tfstate-demola-2026"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "wp-migration-tf-locks"
    encrypt        = true
  }
}
