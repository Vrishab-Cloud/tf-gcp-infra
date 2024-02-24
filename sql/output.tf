output "db_instance_name" {
  value = google_sql_database_instance.mysql_instance.name
}

output "db_user" {
  value = google_sql_user.users.name
}

output "db_password" {
  value = google_sql_user.users.password
}
