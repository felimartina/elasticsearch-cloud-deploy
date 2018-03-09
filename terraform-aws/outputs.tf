output "kibana_dns" {
  value = "${aws_lb.elasticsearch_lb.dns_name}"
}

output "graphana_dns" {
  value = "${aws_lb.elasticsearch_lb.dns_name}:3000"
}

output "es_dns" {
  value = "${aws_lb.elasticsearch_lb.dns_name}:9200"
}
