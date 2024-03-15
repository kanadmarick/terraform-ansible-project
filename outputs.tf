## vi outputs.tf

## Outputs to be displayed after "terraform run"

output "public_ip" {
  value = aws_instance.slave.public_ip
}

output "public_dns" {
  value = aws_instance.slave.public_dns
}
