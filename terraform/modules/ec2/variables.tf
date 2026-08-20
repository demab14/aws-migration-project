variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "public_subnet_id" {
  description = "Subnet the EC2 instance itself lives in"
  type        = string
}

variable "public_subnet_ids" {
  description = "All public subnets, for the ALB"
  type        = list(string)
}

variable "ec2_sg_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access"
  type        = string
}

variable "instance_profile_name" {
  type = string
}
