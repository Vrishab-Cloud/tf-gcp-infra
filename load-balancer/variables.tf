variable "name" {
  type = string
}

variable "port_name" {
  type = string
}

variable "load_balancing_scheme" {
  type = string
}

variable "protocol" {
  type = string
}

variable "balancing_mode" {
  type = string
}

variable "instance_group" {
  type = string
}

variable "autohealing_name" {
  type = string
}

variable "autohealing_check_interval" {
  type = number
}

variable "autohealing_timeout" {
  type = number
}

variable "autohealing_healthy_threshold" {
  type = number
}

variable "autohealing_unhealthy_threshold" {
  type = number
}

variable "health_check_path" {
  type = string
}

variable "app_port" {
  type = number
}

variable "health_check_host" {
  type = string
}
