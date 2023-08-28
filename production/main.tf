terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

provider "ncloud" {
  access_key  = var.NCP_ACCESS_KEY
  secret_key  = var.NCP_SECRET_KEY
  region      = "KR"
  support_vpc = true
}

module "network" {
  source = "../modules/network"

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
  env            = var.env
}

module "db_server" {
  source = "../modules/server"

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
  env            = var.env
  name           = "db"
  vpc_no         = module.network.vpc_no
  subnet_no      = module.network.server_subnet_no
  private_ip     = cidrhost(data.ncloud_subnet.server.subnet, 6)
  init_env = {
    password          = var.password
    postgres_db       = var.postgres_db
    postgres_user     = var.postgres_user
    postgres_password = var.postgres_password
    postgres_port     = var.postgres_port
    ncr_registry      = var.ncr_registry
    docker_user       = var.NCP_ACCESS_KEY
    docker_password   = var.NCP_SECRET_KEY
    django_secret_key = var.django_secret_key
    django_mode       = "prod"
    db_host           = "localhost"
  }
}

module "be_server" {
  source = "../modules/server"

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
  env            = var.env
  name           = "be"
  vpc_no         = module.network.vpc_no
  subnet_no      = module.network.server_subnet_no
  private_ip     = cidrhost(data.ncloud_subnet.server.subnet, 7)
  init_env = {
    password          = var.password
    postgres_db       = var.postgres_db
    postgres_user     = var.postgres_user
    postgres_password = var.postgres_password
    postgres_port     = var.postgres_port
    ncr_registry      = var.ncr_registry
    docker_user       = var.NCP_ACCESS_KEY
    docker_password   = var.NCP_SECRET_KEY
    django_secret_key = var.django_secret_key
    django_mode       = "prod"
    db_host           = module.db_server.public_ip
  }
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
  NCP_SECRET_KEY = var.NCP_SECRET_KEY
  env            = var.env
  vpc_no         = module.network.vpc_no
  subnet_no      = module.network.loadbalancer_subnet_no
  server_list    = [module.be_server.server_id]
}

data "ncloud_subnet" "server" {
  id = module.network.server_subnet_no
}
