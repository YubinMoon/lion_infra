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

variable "name" {
  type = string
}

variable "vpc_no" {
  type = number
}

variable "subnet_no" {
  type = number
}

variable "private_ip" {
  type = string
}

variable "server_image_product_code" {
  type    = string
  default = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"
}

variable "init_env" {
  type = map(any)
}
