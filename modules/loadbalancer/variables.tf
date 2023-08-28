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

variable "vpc_no" {
  type = number
}

variable "subnet_no" {
  type = number
}

variable "server_list" {
  type = list(number)
}
