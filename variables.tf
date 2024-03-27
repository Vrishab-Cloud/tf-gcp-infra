variable "gcp_project" {
  type        = string
  description = "Project to use for this config"
}
variable "gcp_region" {
  type        = string
  description = "Region to use for GCP provider"
  default     = "us-east1"
}

#VPC
variable "vpc_configs" {
  type = object({
    name                   = string
    webapp_ip_cidr         = string
    db_ip_cidr             = string
    routing_mode           = string
    region                 = optional(string, "us-east1")
    webapp_tags            = list(string)
    connector_ip_range     = string
    connector_name         = string
    connector_machine_type = optional(string, "f1-micro")
  })
}

# VM
variable "vm_configs" {
  type = object({
    name            = string
    machine_type    = string
    zone            = optional(string, "us-east1-b")
    boot_disk_image = string
    boot_disk_type  = string
    boot_disk_size  = number
    network_tier    = optional(string, "STANDARD")
    logger_id       = optional(string, "logger")
    logger_name     = optional(string, "logger")
    roles           = optional(set(string))
  })
}

variable "internal_ip_address" {
  type = string
}

variable "internal_ip_name" {
  type = string
}

variable "forwarding_rule_name" {
  type = string
}


variable "sql_configs" {
  type = object({
    db_name              = string
    deletion_protection  = optional(bool, false)
    instance_name_prefix = string
    disk_type            = string
    disk_size            = number
    instance_region      = optional(string, "us-east1")
    db_version           = optional(string, "MYSQL_5_7")
    availability_type    = optional(string, "REGIONAL")
    consumer_projects    = optional(list(string), [])
    sql_user             = optional(string, "admin")
    db_tier              = optional(string, "db-f1-micro")
  })
}

variable "dns_zone_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "dns_record_ttl" {
  type = number
}

variable "pubsub_configs" {
  type = object({
    topic_name             = string
    msg_retention_duration = string
    sub_expire_ttl         = string
    region                 = optional(string, "us-east1")
    function_name          = optional(string, "serverless")
    service_account_id     = string
    available_memory       = string
    runtime                = string
    entry_point            = string
    bucket_name            = string
    bucket_object_name     = string
    roles                  = set(string)
  })
}

variable "mail_api_key" {
  type = string
}

variable "email_link_timeout" {
  type = number
}
