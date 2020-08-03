//  Output the load balancer DNS.
output "alb_dns" {
  value = aws_lb.cluster-alb.dns_name
}
