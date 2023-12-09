output "web_public_ip" {
  description = "The public IP address of the web server"
  value       = aws_eip.web_eip[0].public_ip
  depends_on = [aws_eip.web_eip]
}

output "web_public_dns" {
  description = "The public DNS address of the web server"
  value       = aws_eip.web_eip[0].public_dns

  depends_on = [aws_eip.web_eip]
}

output "load_balancer_endpoint" {
  description = "The public DNS address of the load balancer"
  value       = aws_lb.web_lb.dns_name
}