output "cluster_address" {
  value = "http://${aws_instance.server[0].public_ip}:4646"
}
