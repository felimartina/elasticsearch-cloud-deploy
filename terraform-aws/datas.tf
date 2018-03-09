data "template_file" "data_userdata_script" {
  template = "${file("${path.module}/../templates/user_data.sh")}"

  vars {
    cloud_provider         = "aws"
    volume_name            = "${var.volume_name}"
    elasticsearch_data_dir = "${var.elasticsearch_data_dir}"
    elasticsearch_logs_dir = "${var.elasticsearch_logs_dir}"
    heap_size              = "${var.data_heap_size}"
    es_cluster             = "${var.es_cluster}"
    es_environment         = "${var.environment}-${var.es_cluster}"
    security_groups        = "${aws_security_group.elasticsearch_security_group.id}"
    aws_region             = "${var.aws_region}"
    availability_zones     = "${join(",",var.availability_zones)}"
    minimum_master_nodes   = "${format("%d", var.masters_count / 2 + 1)}"
    master                 = "false"
    data                   = "true"
    http_enabled           = "true"
    security_enabled       = "${var.security_enabled}"
    monitoring_enabled     = "${var.monitoring_enabled}"
    client_user            = ""
    client_pwd             = ""
  }
}

resource "aws_launch_configuration" "data" {
  name_prefix                 = "elasticsearch-${var.es_cluster}-data-nodes"
  image_id                    = "${data.aws_ami.elasticsearch.id}"
  instance_type               = "${var.datas_instance_type}"
  security_groups             = ["${aws_security_group.elasticsearch_security_group.id}"]
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.elasticsearch.id}"
  user_data                   = "${data.template_file.data_userdata_script.rendered}"
  key_name                    = "${var.key_name}"

  ebs_optimized = true

  lifecycle {
    create_before_destroy = true
  }

  ebs_block_device {
    device_name = "${var.volume_name}"
    volume_size = "${var.elasticsearch_volume_size}"
    encrypted   = "${var.volume_encryption}"
  }
}

resource "aws_autoscaling_group" "data_nodes" {
  name                 = "elasticsearch-${var.es_cluster}-data-nodes"
  max_size             = "${var.datas_count}"
  min_size             = "${var.datas_count}"
  desired_capacity     = "${var.datas_count}"
  default_cooldown     = 30
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.data.id}"

  vpc_zone_identifier = ["${var.vpc_private_subnet_ids}"]

  depends_on = ["aws_autoscaling_group.master_nodes"]

  tag {
    key                 = "Name"
    value               = "${format("%s-data-node", var.es_cluster)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster"
    value               = "${var.environment}-${var.es_cluster}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "data"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "data_nodes_scale_out" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.data_nodes.name}"
  cooldown               = "60"                                                          // Give it 60 secods to the alarm to cool down
  name                   = "elasticsearch-${var.es_cluster}-data-nodes-scale-out-policy"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = 1                                                             // Add 1 instance
}

resource "aws_autoscaling_policy" "data_nodes_scale_in" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = "${aws_autoscaling_group.data_nodes.name}"
  cooldown               = "60"                                                         // Give it 60 secods to the alarm to cool down
  name                   = "elasticsearch-${var.es_cluster}-data-nodes-scale-in-policy"
  policy_type            = "SimpleScaling"
  scaling_adjustment     = -1                                                           // Add 1 instance
}

## Creates CloudWatch monitor
resource "aws_cloudwatch_metric_alarm" "data_nodes_monitor_scale_out" {
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.data_nodes_scale_out.arn}"]
  alarm_description   = "Monitors ES data nodes CPU Utilization"
  alarm_name          = "elasticsearch-${var.es_cluster}-data-nodes-asg-monitor-scale_out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"                                                    // periods of 5 minutes
  evaluation_periods  = "1"
  statistic           = "Average"
  threshold           = "60"
  treat_missing_data  = "missing"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.data_nodes.name}"
  }
}

## Creates CloudWatch monitor
resource "aws_cloudwatch_metric_alarm" "data_nodes_monitor_scale_in" {
  actions_enabled     = true
  alarm_actions       = ["${aws_autoscaling_policy.data_nodes_scale_in.arn}"]
  alarm_description   = "Monitors ES data nodes CPU Utilization"
  alarm_name          = "elasticsearch-${var.es_cluster}-data-nodes-asg-monitor-scale-in"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"                                                    // periods of 5 minutes
  evaluation_periods  = "1"
  statistic           = "Average"
  threshold           = "40"
  treat_missing_data  = "missing"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.data_nodes.name}"
  }
}
