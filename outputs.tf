output "instance_eip_addr" {
  value = aws_eip.test_instnc.public_ip
}

output "prod_ip_addrs" {
  value = aws_elb.prod_instnc.dns_name
}
