output "vm_key_id" {
  value = google_kms_crypto_key.vm_key.id
}

output "sql_key_id" {
  value = google_kms_crypto_key.sql_key.id
}

output "bucket_key_id" {
  value = google_kms_crypto_key.bucket_key.id
}
