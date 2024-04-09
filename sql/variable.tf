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
}

variable "sql_user" {
  type = string
}

variable "tier" {
  type = string
}

variable "encryption_id" {
  type = string
}
