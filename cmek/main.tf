resource "google_kms_key_ring" "key_ring" {
  name     = var.key_ring_name
  location = var.location
  lifecycle {
    prevent_destroy = false
  }
}


resource "google_kms_crypto_key" "sql_key" {
  name = var.sql_key_name

  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [google_kms_key_ring.key_ring]
}


resource "google_kms_crypto_key" "vm_key" {
  name = var.vm_key_name

  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [google_kms_key_ring.key_ring]
}

resource "google_kms_crypto_key" "bucket_key" {
  name = var.bucket_key_name

  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [google_kms_key_ring.key_ring]
}

resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  project  = var.project_id
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "sql_binding" {
  crypto_key_id = google_kms_crypto_key.sql_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}",
  ]
}

resource "google_kms_crypto_key_iam_binding" "vm_binding" {

  crypto_key_id = google_kms_crypto_key.vm_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-981472826398@compute-system.iam.gserviceaccount.com",
  ]
}

resource "google_kms_crypto_key_iam_binding" "bucket_binding" {

  crypto_key_id = google_kms_crypto_key.bucket_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-981472826398@gs-project-accounts.iam.gserviceaccount.com",
  ]
}
