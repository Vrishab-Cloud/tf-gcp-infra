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

module "my_vpc" {
  source      = "./vpc"
  vpc_configs = var.vpc_configs
}

module "vm" {
  source          = "./vm"
  vm_name         = var.vm_name
  machine_type    = var.machine_type
  zone            = var.zone
  boot_disk_image = var.boot_disk_image
  subnetwork      = var.subnetwork
  boot_disk_size  = var.boot_disk_size
  boot_disk_type  = var.boot_disk_type
}
