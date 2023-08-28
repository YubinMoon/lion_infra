variable "NCP_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "NCP_SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "env" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "postgres_db" {
  type      = string
  sensitive = true
}

variable "postgres_user" {
  type      = string
  sensitive = true
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_port" {
  type    = string
  default = "5432"
}

variable "ncr_registry" {
  type    = string
  default = "limeskin.kr.ncr.ntruss.com"
}

variable "django_secret_key" {
  type      = string
  sensitive = true
}
