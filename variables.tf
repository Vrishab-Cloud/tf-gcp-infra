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
  })
}

# VM
variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the VM"
  type        = string
}

variable "zone" {
  description = "Zone for the VM"
  type        = string
  default     = "us-east1-b"
}

variable "boot_disk_image" {
  description = "Custom Image for the disk"
  type        = string
}

variable "boot_disk_type" {
  description = "Disk Type"
  type        = string
}

variable "boot_disk_size" {
  description = "Disk Size"
  type        = number
}

variable "subnetwork" {
  description = "VPC subnetwork to launch the VM in"
  type        = string
}

variable "network_tier" {
  description = "Network tier"
  type        = string
  default     = "STANDARD"
}
