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
  gcp_project = var.gcp_project
  vpc_configs = var.vpc_configs
}
