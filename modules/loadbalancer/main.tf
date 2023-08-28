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

data "ncloud_vpc" "main" {
  id = var.vpc_no
}

data "ncloud_subnet" "main" {
  id = var.subnet_no
}

resource "ncloud_lb" "main" {
  name           = "${var.env}-lb"
  network_type   = "PUBLIC"
  type           = "NETWORK_PROXY"
  subnet_no_list = [data.ncloud_subnet.main.subnet_no]
}

resource "ncloud_lb_target_group" "main" {
  name           = "${var.env}-tg"
  port           = 8000
  protocol       = "PROXY_TCP"
  target_type    = "VSVR"
  vpc_no         = data.ncloud_vpc.main.vpc_no
  algorithm_type = "RR"
  health_check {
    protocol       = "TCP"
    http_method    = "GET"
    port           = 8000
    url_path       = "/admin"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
}

resource "ncloud_lb_target_group_attachment" "main" {
  target_group_no = ncloud_lb_target_group.main.target_group_no
  target_no_list  = var.server_list
}

resource "ncloud_lb_listener" "main" {
  load_balancer_no = ncloud_lb.main.load_balancer_no
  target_group_no  = ncloud_lb_target_group.main.target_group_no
  protocol         = "TCP"
  port             = 80
}
