output "webapp_subnet_name" {
  value = google_compute_subnetwork.subnet_webapp.name
}

output "db_subnet_name" {
  value = google_compute_subnetwork.subnet_db.name
}

output "vpc_id" {
  value = google_compute_network.vpc_network.id
}

output "webapp_firewall_tags" {
  value = google_compute_firewall.default.target_tags
}
