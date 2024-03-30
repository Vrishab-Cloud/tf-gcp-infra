resource "google_compute_global_address" "lb" {
  name       = var.name
  ip_version = "IPV4"
}

resource "google_compute_health_check" "autohealing" {
  name                = var.autohealing_name
  check_interval_sec  = var.autohealing_check_interval
  timeout_sec         = var.autohealing_timeout
  healthy_threshold   = var.autohealing_healthy_threshold
  unhealthy_threshold = var.autohealing_unhealthy_threshold

  http_health_check {
    request_path = var.health_check_path
    port         = var.app_port
    host         = var.health_check_host
  }
}

resource "google_compute_backend_service" "webapp" {
  name                            = "webapp-backend-service"
  connection_draining_timeout_sec = 180
  health_checks                   = [google_compute_health_check.autohealing.id]
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
    enable = true
    sample_rate = 1
  }

}

resource "google_compute_url_map" "lb_url_map" {
  name            = "web-map-http"
  default_service = google_compute_backend_service.webapp.id
}

resource "google_compute_target_https_proxy" "lb_https_proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.lb_url_map.id

  ssl_certificates = [
    var.ssl_certificate_name
  ]
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-content-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.lb_https_proxy.id
  ip_address            = google_compute_global_address.lb.id
}
