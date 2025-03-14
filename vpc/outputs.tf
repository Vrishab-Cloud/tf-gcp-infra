output "webapp_subnet" {
  value = google_compute_subnetwork.subnet_webapp.id
}

output "db_subnet" {
  value = google_compute_subnetwork.subnet_db.id
}

output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "webapp_firewall_tags" {
  value = var.webapp_tags
}
