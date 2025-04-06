resource "google_pubsub_topic" "pubsub_topic" {
  name                       = var.topic_name
  message_retention_duration = var.msg_retention_duration
}

resource "google_service_account" "serverless" {
  account_id   = var.service_account_id
  display_name = "Pub Sub subscriber"
}

resource "google_project_iam_binding" "serverless-roles" {
  for_each = var.roles
  project  = var.project_id
  role     = each.key

  members = [
    "serviceAccount:${google_service_account.serverless.email}",
  ]
}

resource "google_secret_manager_secret" "mailgun_api_key" {
  secret_id = "mailgun-api-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "mailgun_api_key_version" {
  secret      = google_secret_manager_secret.mailgun_api_key.id
  secret_data = var.mail_api_key
}

resource "google_secret_manager_secret_iam_member" "serverless_secret_access" {
  secret_id = google_secret_manager_secret.mailgun_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.serverless.email}"
}

data "google_storage_bucket" "my-bucket" {
  name = var.bucket_name
}

resource "google_cloudfunctions2_function" "serverless" {
  name     = var.function_name
  location = var.region

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = data.google_storage_bucket.my-bucket.name
        object = var.bucket_object_name
      }
    }
  }

  service_config {
    max_instance_count = 1
    min_instance_count = 0
    available_memory   = var.available_memory
    timeout_seconds    = 60

    environment_variables = {
      PROD_DB_NAME = var.env_config.db_name
      PROD_DB_USER = var.env_config.db_user
      PROD_DB_PASS = var.env_config.db_pass
      PROD_HOST    = var.env_config.db_host
      DOMAIN_NAME  = var.env_config.domain_name
    }

    secret_environment_variables {
      key        = "MAILGUN_API_KEY"
      project_id = var.project_id
      secret     = google_secret_manager_secret.mailgun_api_key.secret_id
      version    = "latest"
    }

    service_account_email         = google_service_account.serverless.email
    vpc_connector                 = var.vpc_connector
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
    ingress_settings              = "ALLOW_INTERNAL_ONLY"
  }

  event_trigger {
    trigger_region        = var.region
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = google_pubsub_topic.pubsub_topic.id
    service_account_email = google_service_account.serverless.email
    retry_policy          = "RETRY_POLICY_RETRY"
  }

  depends_on = [
    google_project_iam_binding.serverless-roles,
    google_secret_manager_secret_version.mailgun_api_key_version
  ]
}
