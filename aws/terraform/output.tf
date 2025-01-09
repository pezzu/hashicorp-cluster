output "nomad_address" {
  value = "http://${aws_instance.server[0].public_ip}:4646"
}

output "consul_address" {
  value = "http://${aws_instance.server[0].public_ip}:8500"
}

output "vault_address" {
  value = "http://${aws_instance.server[0].public_ip}:8200"
}

output "server_config" {
  value = <<EOF
UI is available at:
Nomad  :  http://${aws_instance.server[0].public_ip}:4646/ui
Consul :  http://${aws_instance.server[0].public_ip}:8500/ui
Vault  :  http://${aws_instance.server[0].public_ip}:8200/ui

CLI configuration:
export NOMAD_ADDR=http://${aws_instance.server[0].public_ip}:4646
export CONSUL_HTTP_ADDR=http://${aws_instance.server[0].public_ip}:8500
export VAULT_ADDR=http://${aws_instance.server[0].public_ip}:8200
EOF
}

output "client_ip" {
  value = aws_instance.client[0].public_ip
}

# output "server_lb_ip" {
#   value = aws_elb.server_lb.dns_name
# }

