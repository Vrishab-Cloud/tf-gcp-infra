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
  source                 = "./vpc"
  name                   = var.vpc_configs.name
  webapp_ip_cidr         = var.vpc_configs.webapp_ip_cidr
  db_ip_cidr             = var.vpc_configs.db_ip_cidr
  routing_mode           = var.vpc_configs.routing_mode
  region                 = var.vpc_configs.region
  webapp_tags            = var.vpc_configs.webapp_tags
  connector_name         = var.vpc_configs.connector_name
  connector_ip_range     = var.vpc_configs.connector_ip_range
  connector_machine_type = var.vpc_configs.connector_machine_type
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

data "google_dns_managed_zone" "dns_zone" {
  name = var.dns_zone_name
}

module "pubsub" {
  source                 = "./pubsub"
  project_id             = var.gcp_project
  region                 = var.gcp_region
  mail_api_key           = var.mail_api_key
  service_account_id     = var.pubsub_configs.service_account_id
  sub_expire_ttl         = var.pubsub_configs.sub_expire_ttl
  dns_name               = data.google_dns_managed_zone.dns_zone.dns_name
  topic_name             = var.pubsub_configs.topic_name
  function_name          = var.pubsub_configs.function_name
  msg_retention_duration = var.pubsub_configs.msg_retention_duration
  available_memory       = var.pubsub_configs.available_memory
  runtime                = var.pubsub_configs.runtime
  entry_point            = var.pubsub_configs.entry_point
  bucket_name            = var.pubsub_configs.bucket_name
  bucket_object_name     = var.pubsub_configs.bucket_object_name
  roles                  = var.pubsub_configs.roles
  vpc_connector          = module.vpc.db_vpc_connector
  env_config = {
    db_name     = module.sql.db_name
    db_user     = module.sql.db_instance_user
    db_pass     = module.sql.db_instance_password
    db_host     = google_compute_address.internal_ip.address
    domain_name = var.domain_name
    api_key     = var.mail_api_key
  }
  depends_on = [module.sql, google_compute_address.internal_ip]
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
  roles                  = var.vm_configs.roles
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
      echo "GCP_PROJECT=${var.gcp_project}" >> /tmp/.env
      echo "TOPIC=${module.pubsub.topic_name}" >> /tmp/.env

      mv /tmp/.env /opt/webapp/app
      chown csye6225:csye6225 /opt/webapp/app/.env

      systemctl start webapp
      systemctl restart google-cloud-ops-agent

      EOT
  depends_on             = [google_compute_address.internal_ip, module.sql, module.vpc, module.pubsub]
}

resource "google_dns_record_set" "default" {
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  name         = data.google_dns_managed_zone.dns_zone.dns_name
  type         = "A"
  rrdatas      = [module.vm.vm_external_ip]
  ttl          = var.dns_record_ttl

  depends_on = [module.vm]
}
