terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>5.0"
    }
  }
}

module "cmek" {
  source          = "./cmek"
  project_id      = var.gcp_project
  location        = var.cmek_configs.location
  sql_key_name    = var.cmek_configs.sql_key_name
  vm_key_name     = var.cmek_configs.vm_key_name
  bucket_key_name = var.cmek_configs.bucket_key_name
  key_ring_name   = var.cmek_configs.key_ring_name
  rotation_period = var.cmek_configs.rotation_period
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
  gfe_proxies            = var.gfe_proxies
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
  encryption_id        = module.cmek.sql_key_id

  depends_on = [module.cmek]

}

resource "google_compute_address" "internal_ip" {
  name         = var.internal_ip_name
  address_type = "INTERNAL"
  address      = var.internal_ip_address
  subnetwork   = module.vpc.db_subnet_name
  region       = var.gcp_region

  depends_on = [module.vpc]
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

  depends_on = [module.vpc]
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

  depends_on = [module.cmek, module.vpc, module.sql, google_compute_address.internal_ip]
}

resource "google_compute_health_check" "autohealing" {
  name                = var.autohealing_configs.name
  check_interval_sec  = var.autohealing_configs.check_interval
  timeout_sec         = var.autohealing_configs.timeout
  healthy_threshold   = var.autohealing_configs.healthy_threshold
  unhealthy_threshold = var.autohealing_configs.unhealthy_threshold

  http_health_check {
    request_path = var.autohealing_configs.health_check_path
    port         = var.app_port
    host         = google_compute_address.internal_ip.address
  }

  depends_on = [google_compute_address.internal_ip]
}

module "vm-template" {
  source                 = "./vm-template"
  gcp_project_id         = var.gcp_project
  prefix_name            = var.vm_configs.name
  machine_type           = var.vm_configs.machine_type
  region                 = var.vm_configs.region
  boot_disk_image        = var.vm_configs.boot_disk_image
  subnetwork             = module.vpc.webapp_subnet_name
  boot_disk_size         = var.vm_configs.boot_disk_size
  boot_disk_type         = var.vm_configs.boot_disk_type
  tags                   = module.vpc.webapp_firewall_tags
  network_tier           = var.vm_configs.network_tier
  service_account_id     = var.vm_configs.logger_id
  service_account_name   = var.vm_configs.logger_name
  service_account_scopes = var.vm_configs.service_account_scopes
  roles                  = var.vm_configs.roles
  group_manager_name     = var.vm_configs.instance_manager_name
  health_check_id        = google_compute_health_check.autohealing.id
  app_port               = var.app_port

  autoscaler_name            = var.autoscaler_configs.name
  autoscaler_cpu_utilization = var.autoscaler_configs.cpu_utilization
  autoscaler_cooldown_period = var.autoscaler_configs.cooldown_period
  max_replicas               = var.autoscaler_configs.max_replicas
  min_replicas               = var.autoscaler_configs.min_replicas
  encryption_id              = module.cmek.vm_key_id
  startup_script_content     = <<-EOT
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
      echo "EMAIL_LINK_TIMEOUT=${var.email_link_timeout}" >> /tmp/.env

      mv /tmp/.env /opt/webapp/app
      chown csye6225:csye6225 /opt/webapp/app/.env

      systemctl start webapp
      systemctl restart google-cloud-ops-agent

      EOT
  depends_on                 = [module.vpc, google_compute_address.internal_ip, module.cmek, module.sql, google_compute_health_check.autohealing]
}

resource "google_compute_managed_ssl_certificate" "lb_default" {
  name = var.ssl_certificate_name

  managed {
    domains = [var.domain_name]
  }
}

module "load-balancer" {
  source                = "./load-balancer"
  name                  = var.lb_configs.name
  balancing_mode        = var.lb_configs.balancing_mode
  load_balancing_scheme = var.lb_configs.load_balancing_scheme
  protocol              = var.lb_configs.protocol
  port_name             = module.vm-template.port_name
  port_range            = var.lb_configs.port_range
  instance_group        = module.vm-template.instance_group
  health_check_id       = google_compute_health_check.autohealing.id
  ssl_certificate_name  = google_compute_managed_ssl_certificate.lb_default.name
  depends_on            = [module.vm-template, google_compute_managed_ssl_certificate.lb_default]
}

resource "google_dns_record_set" "default" {
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  name         = data.google_dns_managed_zone.dns_zone.dns_name
  type         = "A"
  rrdatas      = [module.load-balancer.ip_address]
  ttl          = var.dns_record_ttl

  depends_on = [module.load-balancer]
}

resource "demo" "demo" {}
