# Create Autoscaling Group using the Launch Configuration jenkinslc
resource "aws_autoscaling_group" "jenkinsasg" {
  name                 = "jenkins_asg"
  launch_configuration = aws_launch_configuration.jenkinslc.name
  vpc_zone_identifier  = (tolist(data.aws_subnet_ids.default.ids))

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  min_size          = 1
  max_size          = 1

  tag {
    key                 = "Name"
    value               = "terraform-asg-jenkins"
    propagate_at_launch = true
  }

  # Create a new instance before deleting the old one
  lifecycle {
    create_before_destroy = true
  }
}

# Create an Application Load Balancer
resource "aws_lb" "jenkinsalb" {
  name               = "jenkins-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.albSG.id]

}
resource "aws_lb_target_group" "asg" {
  name     = "asg-TG"
  port     = var.jenkins_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  # Configure Health Check for Target Group
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "403"
    interval            = 15
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 10
  }
}
