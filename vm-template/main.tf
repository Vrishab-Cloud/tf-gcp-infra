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

resource "google_compute_region_instance_template" "instance_template" {
  name_prefix  = var.prefix_name
  machine_type = var.machine_type
  region       = var.region

  tags = var.tags

  disk {
    source_image = var.boot_disk_image
    boot         = true
    disk_type    = var.boot_disk_type
    disk_size_gb = var.boot_disk_size
  }

  network_interface {

    access_config {
      network_tier = var.network_tier
    }

    subnetwork = var.subnetwork
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    email = google_service_account.service_account.email
    scopes = var.service_account_scopes
  }

  metadata_startup_script = var.startup_script_content
}


resource "google_compute_region_autoscaler" "autoscaler" {
  name   = var.autoscaler_name
  region = var.region
  target = google_compute_region_instance_group_manager.instance_group_manager.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.autoscaler_cooldown_period

    cpu_utilization {
      target = var.autoscaler_cpu_utilization
    }
  }
}

resource "google_compute_region_instance_group_manager" "instance_group_manager" {
  name               = var.group_manager_name
  base_instance_name = "${var.prefix_name}instance-group-manager"
  region             = var.region
  version {
    instance_template = google_compute_region_instance_template.instance_template.id
  }

  named_port {
    name = "http"
    port = var.app_port
  }
}
