variable "db_name" {
  type = string
}

variable "deletion_protection" {
  type = bool
}

variable "instance_name_prefix" {
  type = string
}

variable "instance_region" {
  type = string
}

variable "db_version" {
  type = string
}

variable "availability_type" {
  type = string
}

variable "disk_type" {
  type = string
}

variable "disk_size" {
  type = string
}

variable "consumer_projects" {
  type = list(string)
  # default = []
}

variable "private_network" {
  type = string
}

variable "sql_user" {
  type = string
}
