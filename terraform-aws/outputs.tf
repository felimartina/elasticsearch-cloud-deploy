output "clients_dns" {
  value = "${aws_lb.es_client_lb.dns_name}"
}
