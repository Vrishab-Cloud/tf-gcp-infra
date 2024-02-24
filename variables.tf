variable "gcp_project" {
  type        = string
  description = "Project to use for this config"
}

variable "vpc_region" {
  type        = string
  description = "Region to use for GCP provider"
  default     = "us-east1"
}

#VPC
variable "vpc_configs" {
  type = object({
    name           = string
    webapp_ip_cidr = string
    db_ip_cidr     = string
    routing_mode   = string
    region         = optional(string, "us-east1")
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
