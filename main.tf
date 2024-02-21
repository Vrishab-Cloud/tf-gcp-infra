terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.0"
    }
  }
}

provider "google" {
  region  = var.vpc_region
  project = var.gcp_project
}

module "vpc" {
  source         = "./vpc"
  name           = var.vpc_configs.name
  webapp_ip_cidr = var.vpc_configs.webapp_ip_cidr
  db_ip_cidr     = var.vpc_configs.db_ip_cidr
  routing_mode   = var.vpc_configs.routing_mode
}

module "vm" {
  source          = "./vm"
  vm_name         = var.vm_name
  machine_type    = var.machine_type
  zone            = var.zone
  boot_disk_image = var.boot_disk_image
  subnetwork      = module.vpc.webapp_subnet_name
  boot_disk_size  = var.boot_disk_size
  boot_disk_type  = var.boot_disk_type
  tags            = module.vpc.webapp_firewall_tags
}
