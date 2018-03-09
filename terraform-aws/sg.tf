resource "aws_security_group" "elasticsearch_security_group" {
  name        = "elasticsearch-${var.es_cluster}-security-group"
  description = "Elasticsearch ports with ssh"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(var.global_tags,map("Name","${var.es_cluster}-elasticsearch-sg"))}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.admin_cidrs}"]
    description = "Allow SSH access to admin users"
  }

  ingress {
    from_port   = 9200
    to_port     = 9400
    protocol    = "tcp"
    self        = true
    description = "Inter-cluster communication over ports 9200-9400"
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    self        = true
    description = "Allow inter-cluster ping"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbounb traffic"
  }
}

resource "aws_security_group" "elasticsearch_clients_security_group" {
  name        = "elasticsearch-${var.es_cluster}-clients-security-group"
  description = "Allows access to app ports from public subnets"
  vpc_id      = "${var.vpc_id}"
  tags        = "${merge(var.global_tags,map("Name","${var.es_cluster}-client-sg"))}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_public_subnets_cidrs}"]
    description = "Allow HTTP access to 8080 for Kibana from public subnets"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_public_subnets_cidrs}"]
    description = "Allow HTTP access to 3000 for Grafana from public subnets"
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_public_subnets_cidrs}"]
    description = "Allow HTTP access to 9200 for ES from public subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbounb traffic"
  }
}

resource "aws_security_group" "elasticsearch_public_lb_security_group" {
  name        = "elasticsearch-${var.es_cluster}-public-lb-security-group"
  description = "Allows access to app ports for LB from the internet"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(var.global_tags,map("Name","${var.es_cluster}-public-lb-sg"))}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access to 8080 for Kibana from the internet"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access to 3000 for Graphana from the internet"
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access to 9200 for ES from the internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbounb traffic"
  }
}
