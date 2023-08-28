output "vpc_no" {
  value = ncloud_vpc.main.vpc_no
}

output "server_subnet_no" {
  value = ncloud_subnet.server.subnet_no
}

output "loadbalancer_subnet_no" {
  value = ncloud_subnet.loadbalancer.subnet_no
}
