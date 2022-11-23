#---------- Launch Configuration Template ----------
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_launch_configuration" "internal_webserver" {
  name            = "webserver-config"
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  user_data       = file("userdata.tpl")
  security_groups = [var.security_groups]

  lifecycle {
    create_before_destroy = true
  }
}

# ---------- AutoScaling Group ----------
resource "aws_autoscaling_group" "webserver_asg" {
  name                      = "WebServer_AutoScaling"
  max_size                  = 3
  min_size                  = 1
  default_cooldown          = 120
  launch_configuration      = aws_launch_configuration.internal_webserver.id
  health_check_type         = "EC2"
  health_check_grace_period = 30
  termination_policies      = ["OldestInstance"]
  vpc_zone_identifier       = var.private_subnets
  target_group_arns         = [var.target_group_arn]
}

resource "aws_autoscaling_policy" "aws_asg_policy" {
  name                   = "autoscaling_project_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webserver_asg.id
}

resource "aws_cloudwatch_metric_alarm" "WebServer_CPU_Alarm" {
  alarm_name          = "webserver_cpu_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtillization"
  namespace           = "AWS_EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "25"
  alarm_description   = "This metric monitors CPU utilization on EC2 instances."
  alarm_actions       = [aws_autoscaling_policy.aws_asg_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webserver_asg.id
  }
}