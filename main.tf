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
  region         = var.vpc_configs.region
}

module "vm" {
  source          = "./vm"
  name         = var.vm_configs.name
  machine_type    = var.vm_configs.machine_type
  zone            = var.vm_configs.zone
  boot_disk_image = var.vm_configs.boot_disk_image
  subnetwork      = module.vpc.webapp_subnet_name
  boot_disk_size  = var.vm_configs.boot_disk_size
  boot_disk_type  = var.vm_configs.boot_disk_type
  tags            = module.vpc.webapp_firewall_tags
  network_tier    = var.vm_configs.network_tier
}
