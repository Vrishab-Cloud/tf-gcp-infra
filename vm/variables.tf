variable "name" {
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
}

variable "boot_disk_image" {
  description = "Custom Image for the disk"
  type        = string
}

variable "boot_disk_type" {
  description = "Disk Type"
  type        = string
}

variable "tags" {
  description = "Firewall tags to be applied to the VM"
  type        = list(string)
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
}

variable "startup_script_content" {
  description = "Content of the startup script"
  type        = string
}

variable "gcp_project_id" {
  type        = string
  description = "Project to use for IAM config"
}

variable "service_account_id" {
  type        = string
  description = "Id for logger service account"
}

variable "service_account_name" {
  type        = string
  description = "Display name for logger service account"
}

variable "roles" {
  type = set(string)
}
