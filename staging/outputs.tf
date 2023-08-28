output "db_ip" {
  value = module.db_server.public_ip
}

output "be_ip" {
  value = module.be_server.public_ip
}

output "domain" {
  value = module.loadbalancer.domain
}
