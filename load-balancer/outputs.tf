output "ip_address" {
  value = google_compute_global_address.lb.address
}
