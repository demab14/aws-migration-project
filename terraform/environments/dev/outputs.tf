output "wordpress_instance_ip" {
  value = module.ec2.instance_public_ip
}

output "alb_dns_name" {
  value = module.ec2.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "migration_bucket" {
  value = module.s3.bucket_name
}

output "db_secret_id" {
  description = "Secrets Manager secret name Ansible should read DB credentials from"
  value       = module.secrets.secret_id
}
