output "instance_group" {
  value = google_compute_region_instance_group_manager.instance_group_manager.instance_group
}

output "port_name" {
  value = "http"
}
