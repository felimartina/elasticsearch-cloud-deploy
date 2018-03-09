data "template_file" "master_userdata_script" {
  template = "${file("${path.module}/../templates/user_data.sh")}"

  vars {
    cloud_provider         = "aws"
    volume_name            = ""
    elasticsearch_data_dir = "/var/lib/elasticsearch"
    elasticsearch_logs_dir = "${var.elasticsearch_logs_dir}"
    heap_size              = "${var.master_heap_size}"
    es_cluster             = "${var.es_cluster}"
    es_environment         = "${var.environment}-${var.es_cluster}"
    security_groups        = "${aws_security_group.elasticsearch_security_group.id}"
    aws_region             = "${var.aws_region}"
    availability_zones     = "${join(",",var.availability_zones)}"
    minimum_master_nodes   = "${format("%d", var.masters_count / 2 + 1)}"
    master                 = "true"
    data                   = "false"
    http_enabled           = "false"
    security_enabled       = "${var.security_enabled}"
    monitoring_enabled     = "${var.monitoring_enabled}"
    client_user            = ""
    client_pwd             = ""
  }
}

resource "aws_launch_configuration" "master" {
  name_prefix                 = "${var.es_cluster}-elasticsearch-master-launch-conf"
  image_id                    = "${data.aws_ami.elasticsearch.id}"
  instance_type               = "${var.masters_instance_type}"
  security_groups             = ["${aws_security_group.elasticsearch_security_group.id}"]
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.elasticsearch.id}"
  user_data                   = "${data.template_file.master_userdata_script.rendered}"
  key_name                    = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "master_nodes" {
  name                 = "${var.es_cluster}-elasticsearch-master-asg"
  max_size             = "${var.masters_count}"
  min_size             = "${var.masters_count}"
  desired_capacity     = "${var.masters_count}"
  default_cooldown     = 30
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.master.id}"
  vpc_zone_identifier  = ["${var.vpc_private_subnet_ids}"]

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${var.es_cluster}-elasticsearch-master-node", "propagate_at_launch", true),
      map("key", "Role", "value", "master", "propagate_at_launch", true)
    ),
    var.global_tags_for_asg)
  }"]

  lifecycle {
    create_before_destroy = true
  }
}
