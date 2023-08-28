terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.6.0"
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

provider "ssh" {
  # Configuration options
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
  port           = "5432"
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
    django_mode       = "staging"
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
  port           = "8000"
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
    django_mode       = "staging"
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

resource "ssh_resource" "init_db" {
  when = "create"

  host     = module.db_server.public_ip
  user     = "terry"
  password = var.password

  timeout     = "30s"
  retry_delay = "5s"

  file {
    source      = "${path.module}/set_db_server.sh"
    destination = "/home/terry/set_db.sh"
    permissions = "0700"
  }

  commands = [
    ". set_db.sh"
  ]
}

resource "ssh_resource" "init_be" {
  when = "create"

  host     = module.be_server.public_ip
  user     = "terry"
  password = var.password

  timeout     = "30s"
  retry_delay = "5s"

  file {
    source      = "${path.module}/set_be_server.sh"
    destination = "/home/terry/set_be.sh"
    permissions = "0700"
  }

  commands = [
    ". set_be.sh"
  ]
}
