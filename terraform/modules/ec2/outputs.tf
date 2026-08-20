output "instance_id" {
  value = aws_instance.wordpress.id
}

output "instance_public_ip" {
  value = aws_instance.wordpress.public_ip
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
