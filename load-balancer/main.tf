resource "google_compute_global_address" "lb" {
  name       = var.name
  ip_version = "IPV4"
}

resource "google_compute_backend_service" "webapp" {
  name                            = "webapp-backend-service"
  connection_draining_timeout_sec = 180
  health_checks                   = [var.health_check_id]
  load_balancing_scheme           = var.load_balancing_scheme
  port_name                       = var.port_name
  protocol                        = var.protocol
  session_affinity                = "NONE"
  timeout_sec                     = 30
  backend {
    group           = var.instance_group
    balancing_mode  = var.balancing_mode
    capacity_scaler = 1.0
  }
  log_config {
    enable      = true
    sample_rate = 1
  }

}

resource "google_compute_url_map" "lb_url_map" {
  name            = "web-map-http"
  default_service = google_compute_backend_service.webapp.id
}

resource "google_compute_target_https_proxy" "lb_https_proxy" {
  name    = "https-lb-proxy"
  url_map = google_compute_url_map.lb_url_map.id

  ssl_certificates = [
    var.ssl_certificate_name
  ]
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "https-content-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = var.port_range
  target                = google_compute_target_https_proxy.lb_https_proxy.id
  ip_address            = google_compute_global_address.lb.id
}
