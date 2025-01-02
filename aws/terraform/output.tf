output "cluster_address" {
  value = "http://${aws_instance.server[0].public_ip}:4646"
}

# output "server_lb_ip" {
#   value = aws_elb.server_lb.dns_name
# }

