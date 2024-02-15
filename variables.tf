variable "gcp_project" {
  type        = string
  description = "Project to use for this config"
}

variable "vpc_region" {
  type        = string
  description = "Region to use for GCP provider"
  default     = "us-east1"
}

variable "vpc_configs" {
  type = map(object({
    webapp_ip_cidr = string
    db_ip_cidr     = string
  }))
}
