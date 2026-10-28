variable "project" {
  type    = string
  default = "wordpress"
}

variable "instance_id" {
  type        = string
  description = "EC2 instance to watch"
}

variable "db_instance_identifier" {
  type        = string
  description = "RDS DB identifier (the name, not the resource ID)"
}

variable "alarm_email" {
  type        = string
  default     = ""
  description = "Email for alarm notifications; empty = no subscription"
}
