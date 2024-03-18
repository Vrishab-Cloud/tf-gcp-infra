resource "google_service_account" "service_account" {
  account_id   = "logger"
  display_name = "logger"
}

resource "google_project_iam_binding" "logging" {
  project = var.gcp_project_id
  role    = "roles/logging.admin"

  members = [
    google_service_account.service_account.email,
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_project_iam_binding" "monitoring" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    google_service_account.service_account.email,
  ]

  depends_on = [google_service_account.service_account]
}

resource "google_compute_instance" "vm" {

  name         = var.name
  machine_type = var.machine_type

  zone = var.zone
  tags = var.tags
  boot_disk {
    device_name = var.name

    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {

    access_config {
      network_tier = var.network_tier
    }

    subnetwork = var.subnetwork
    stack_type = "IPV4_ONLY"
  }

  service_account {
    email = google_service_account.service_account.email
    scopes = [
      "https://www.googleapis.com/auth/logging.admin",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  metadata_startup_script = var.startup_script_content

  allow_stopping_for_update = true
}
