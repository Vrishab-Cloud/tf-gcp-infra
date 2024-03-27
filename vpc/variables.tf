#VPC
variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "webapp_ip_cidr" {
  type = string
}

variable "db_ip_cidr" {
  type = string
}

variable "routing_mode" {
  type = string
}

variable "webapp_tags" {
  type = list(string)
}

variable "connector_name" {
  type = string
}

variable "connector_ip_range" {
  type = string
}

variable "connector_machine_type" {
  type = string
}
