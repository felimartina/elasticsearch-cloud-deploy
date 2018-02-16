

resource "aws_lb" "es_client_lb" {
  // Only create an ELB if it's not a single-node configuration
  count = "${var.masters_count == "0" && var.datas_count == "0" ? "0" : "1"}"

  name               = "${format("%s-client-lb", var.es_cluster)}"
  security_groups    = ["${aws_security_group.elasticsearch_clients_security_group.id}"]
  subnets            = ["${module.vpc.public_subnets}"]
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = 400

  tags {
    Name = "${format("%s-client-lb", var.es_cluster)}"
  }
}

resource "aws_lb_listener" "graphana" {
  load_balancer_arn = "${aws_lb.es_client_lb.arn}"
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.graphana.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "graphana" {
  name     = "${format("%s-client-lb-tg-graphana", var.es_cluster)}"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_autoscaling_attachment" "graphana" {
  autoscaling_group_name = "${aws_autoscaling_group.client_nodes.id}"
  alb_target_group_arn   = "${aws_lb_target_group.graphana.arn}"
}

resource "aws_lb_listener" "es" {
  load_balancer_arn = "${aws_lb.es_client_lb.arn}"
  port              = "9200"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.es.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "es" {
  name     = "${format("%s-client-lb-tg-es", var.es_cluster)}"
  port     = 9200
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_autoscaling_attachment" "es" {
  autoscaling_group_name = "${aws_autoscaling_group.client_nodes.id}"
  alb_target_group_arn   = "${aws_lb_target_group.es.arn}"
}

resource "aws_lb_listener" "kibana" {
  load_balancer_arn = "${aws_lb.es_client_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.kibana.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "kibana" {
  name     = "${format("%s-client-lb-tg-kibana", var.es_cluster)}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
}

resource "aws_autoscaling_attachment" "kibana" {
  autoscaling_group_name = "${aws_autoscaling_group.client_nodes.id}"
  alb_target_group_arn   = "${aws_lb_target_group.kibana.arn}"
}
