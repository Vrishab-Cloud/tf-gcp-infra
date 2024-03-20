terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.0"
    }
  }
}

provider "google" {
  region  = var.gcp_region
  project = var.gcp_project
}

module "vpc" {
  source         = "./vpc"
  name           = var.vpc_configs.name
  webapp_ip_cidr = var.vpc_configs.webapp_ip_cidr
  db_ip_cidr     = var.vpc_configs.db_ip_cidr
  routing_mode   = var.vpc_configs.routing_mode
  region         = var.vpc_configs.region
  webapp_tags    = var.vpc_configs.webapp_tags
}

module "sql" {
  source               = "./sql"
  db_name              = var.sql_configs.db_name
  db_version           = var.sql_configs.db_version
  deletion_protection  = var.sql_configs.deletion_protection
  instance_name_prefix = var.sql_configs.instance_name_prefix
  disk_size            = var.sql_configs.disk_size
  disk_type            = var.sql_configs.disk_type
  instance_region      = var.sql_configs.instance_region
  availability_type    = var.sql_configs.availability_type
  consumer_projects    = var.sql_configs.consumer_projects
  sql_user             = var.sql_configs.sql_user
  tier                 = var.sql_configs.db_tier
}

resource "google_compute_address" "internal_ip" {
  name         = var.internal_ip_name
  address_type = "INTERNAL"
  address      = var.internal_ip_address
  subnetwork   = module.vpc.db_subnet_name
  region       = var.gcp_region
}
data "google_sql_database_instance" "mysql_instance" {
  name = module.sql.db_instance_name
}


resource "google_compute_forwarding_rule" "forwarding_rule" {
  name                  = var.forwarding_rule_name
  target                = data.google_sql_database_instance.mysql_instance.psc_service_attachment_link
  network               = module.vpc.vpc_id
  ip_address            = google_compute_address.internal_ip.self_link
  load_balancing_scheme = ""
  region                = var.gcp_region
}

module "vm" {
  source                 = "./vm"
  gcp_project_id         = var.gcp_project
  name                   = var.vm_configs.name
  machine_type           = var.vm_configs.machine_type
  zone                   = var.vm_configs.zone
  boot_disk_image        = var.vm_configs.boot_disk_image
  subnetwork             = module.vpc.webapp_subnet_name
  boot_disk_size         = var.vm_configs.boot_disk_size
  boot_disk_type         = var.vm_configs.boot_disk_type
  tags                   = module.vpc.webapp_firewall_tags
  network_tier           = var.vm_configs.network_tier
  service_account_id     = var.vm_configs.logger_id
  service_account_name   = var.vm_configs.logger_name
  startup_script_content = <<-EOT
      #!/bin/bash

      if [ -e "/opt/webapp/app/.env" ]; then
        exit 0
      fi

      touch /tmp/.env

      echo "PROD_DB_NAME=${module.sql.db_name}" >> /tmp/.env
      echo "PROD_DB_USER=${module.sql.db_instance_user}" >> /tmp/.env
      echo "PROD_DB_PASS=${module.sql.db_instance_password}" >> /tmp/.env
      echo "PROD_HOST=${google_compute_address.internal_ip.address}" >> /tmp/.env
      echo "NODE_ENV=production" >> /tmp/.env

      mv /tmp/.env /opt/webapp/app
      chown csye6225:csye6225 /opt/webapp/app/.env

      systemctl start webapp
      systemctl restart google-cloud-ops-agent
      
      EOT
  depends_on             = [google_compute_address.internal_ip]
}

data "google_dns_managed_zone" "dns_zone" {
  name = var.dns_zone_name
}
resource "google_dns_record_set" "default" {
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  name         = data.google_dns_managed_zone.dns_zone.dns_name
  type         = "A"
  rrdatas      = [module.vm.vm_external_ip]
  ttl          = var.dns_record_ttl
}
