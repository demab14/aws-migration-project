output "db_endpoint" {
  value = aws_db_instance.wordpress.address
}

output "db_port" {
  value = aws_db_instance.wordpress.port
}

output "db_name" {
  value = aws_db_instance.wordpress.db_name
}
