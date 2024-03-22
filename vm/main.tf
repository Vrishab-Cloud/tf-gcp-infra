resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_name
}

resource "google_project_iam_binding" "application-roles" {
  for_each = var.roles
  project  = var.gcp_project_id
  role     = each.key

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
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
      "cloud-platform"
    ]
  }

  metadata_startup_script = var.startup_script_content

  allow_stopping_for_update = true
}
