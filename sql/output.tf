output "db_instance_name" {
  value = google_sql_database_instance.mysql_instance.name
}

output "db_name" {
  value = var.db_name
}

output "db_instance_user" {
  value = google_sql_user.users.name
}

output "db_instance_password" {
  value = google_sql_user.users.password
}
