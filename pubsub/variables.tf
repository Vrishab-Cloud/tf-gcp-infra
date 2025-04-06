variable "dns_name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "mail_api_key" {
  type      = string
  sensitive = true
}

variable "topic_name" {
  type = string
}

variable "msg_retention_duration" {
  type = string
}

variable "sub_expire_ttl" {
  type = string
}

variable "region" {
  type = string
}

variable "service_account_id" {
  type = string
}

variable "roles" {
  type = set(string)
}

variable "function_name" {
  type = string
}

variable "runtime" {
  type = string
}

variable "entry_point" {
  type = string
}

variable "available_memory" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "bucket_object_name" {
  type = string
}

variable "vpc_connector" {
  type = string
}

variable "env_config" {
  type = object({
    db_name     = string
    db_user     = string
    db_pass     = string
    db_host     = string
    domain_name = string
    api_key     = string
  })
}
