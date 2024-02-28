resource "google_compute_network" "vpc_network" {
  name                            = var.name
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "subnet_webapp" {
  name          = "webapp"
  ip_cidr_range = var.webapp_ip_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
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
resource "google_compute_firewall" "allow_http" {
  name    = "webapp-firewall-http"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  direction     = "INGRESS"
  target_tags   = concat(var.webapp_tags, ["http", "ingress"])
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_db" {
  name    = "webapp-firewall-db"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  direction     = "EGRESS"
  target_tags   = concat(var.webapp_tags, ["db", "egress"])
  source_ranges = var.db_source_ranges
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

resource "google_compute_firewall" "deny_others_egress" {
  name    = "webapp-firewall-others-egress"
  network = google_compute_network.vpc_network.id

  deny {
    protocol = "all"
  }

  priority      = 65534
  direction     = "EGRESS"
  source_ranges = ["0.0.0.0/0"]
}
