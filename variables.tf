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
    name             = string
    webapp_ip_cidr   = string
    db_ip_cidr       = string
    routing_mode     = string
    region           = optional(string, "us-east1")
    webapp_tags      = list(string)
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
  })

}

variable "internal_ip_address" {
  type = string
}

variable "internal_ip_name" {
  type = string
}

variable "internal_ip_purpose" {
  type    = string
  default = "PRIVATE_SERVICE_CONNECT"
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
  })
}
