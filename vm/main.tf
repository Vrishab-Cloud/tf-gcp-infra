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

  metadata_startup_script = var.startup_script_content
}
