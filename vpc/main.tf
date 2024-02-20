provider "google" {
  region  = var.vpc_region
  project = var.gcp_project
}

locals {
  vpc_names = keys(var.vpc_configs)

  webapp_ip_cidrs = [for vpc_config in values(var.vpc_configs) : vpc_config.webapp_ip_cidr]

  db_ip_cidrs = [for vpc_config in values(var.vpc_configs) : vpc_config.db_ip_cidr]

  route_modes = [for vpc_config in values(var.vpc_configs) : vpc_config.routing_mode]
}

resource "google_compute_network" "vpc_network" {
  count                           = length(local.vpc_names)
  name                            = local.vpc_names[count.index]
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = local.route_modes[count.index]
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnet_webapp" {
  count         = length(local.webapp_ip_cidrs)
  name          = count.index == 0 ? "webapp" : "${local.vpc_names[count.index]}-webapp"
  ip_cidr_range = local.webapp_ip_cidrs[count.index]
  region        = var.vpc_region
  network       = google_compute_network.vpc_network[count.index].id
}

resource "google_compute_subnetwork" "subnet_db" {
  count         = length(local.db_ip_cidrs)
  name          = count.index == 0 ? "db" : "${local.vpc_names[count.index]}-db"
  ip_cidr_range = local.db_ip_cidrs[count.index]
  region        = var.vpc_region
  network       = google_compute_network.vpc_network[count.index].id
}

resource "google_compute_route" "default" {
  count            = length(local.vpc_names)
  name             = count.index == 0 ? "webapp-route" : "${local.vpc_names[count.index]}-webapp-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_network[count.index].id
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_firewall" "default" {
  count   = length(local.vpc_names)
  name    = count.index == 0 ? "webapp-firewall" : "${local.vpc_names[count.index]}-webapp-firewall"
  network = google_compute_network.vpc_network[count.index].id
  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  direction     = "INGRESS"
  target_tags   = ["http-server"]
  source_ranges = ["0.0.0.0/0"]
}
