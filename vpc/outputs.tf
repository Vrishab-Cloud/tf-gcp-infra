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
  value = var.webapp_tags
}

output "db_vpc_connector" {
  value = google_vpc_access_connector.db_connector.name
}
