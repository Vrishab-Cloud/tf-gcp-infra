resource "google_compute_network" "vpc_network" {
  name                            = var.name
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnet_webapp" {
  name                     = "webapp"
  ip_cidr_range            = var.webapp_ip_cidr
  region                   = var.region
  private_ip_google_access = true
  network                  = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "subnet_db" {
  name          = "db"
  ip_cidr_range = var.db_ip_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
}


resource "google_compute_route" "default" {
  name             = "webapp-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc_network.id
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# Firewall Rules
resource "google_compute_firewall" "allow_health" {
  name      = "webapp-firewall-lb"
  network   = google_compute_network.vpc_network.id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  target_tags   = concat(var.webapp_tags, ["http", "ingress"])
  source_ranges = var.gfe_proxies
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "webapp-ssh"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  target_tags   = concat(var.webapp_tags, ["http", "ingress"])
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "deny_others_ingress" {
  name    = "webapp-firewall-others-ingress"
  network = google_compute_network.vpc_network.id

  deny {
    protocol = "all"
  }

  priority      = 65534
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}
