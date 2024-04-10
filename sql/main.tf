resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_database_instance" "mysql_instance" {

  name                = "${var.instance_name_prefix}-${random_id.db_name_suffix.dec}"
  region              = var.instance_region
  database_version    = var.db_version
  encryption_key_name = var.encryption_id
  settings {
    tier = var.tier

    disk_size         = var.disk_size
    disk_type         = var.disk_type
    availability_type = var.availability_type

    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }

    ip_configuration {
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = var.consumer_projects

      }

      ipv4_enabled = false
    }

  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.mysql_instance.name

  depends_on = [google_sql_database_instance.mysql_instance]
}

resource "google_sql_user" "users" {
  name     = var.sql_user
  instance = google_sql_database_instance.mysql_instance.name
  password = random_password.password.result

  depends_on = [google_sql_database_instance.mysql_instance]
}
