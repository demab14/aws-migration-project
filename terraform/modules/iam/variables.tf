variable "project_name" {
  type = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket used for the migration dump"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding DB credentials"
  type        = string
}
