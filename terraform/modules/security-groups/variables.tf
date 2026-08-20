variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "admin_cidr" {
  description = "CIDR allowed to SSH into the EC2 instance (lock this to your IP, not 0.0.0.0/0)"
  type        = string
}
