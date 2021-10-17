// EFS
resource "aws_efs_file_system" "JenkinsEFS" {
  creation_token   = "Jenkins-EFS"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "true"
  tags = {
    Name = "JenkinsHomeEFS"
  }
}

resource "aws_efs_mount_target" "efs-mt-jenkins" {
  count           = length(tolist(data.aws_subnet_ids.default.ids))
  file_system_id  = aws_efs_file_system.JenkinsEFS.id
  subnet_id       = element(tolist(data.aws_subnet_ids.default.ids), count.index)
  security_groups = [aws_security_group.ingress-efs.id]
}

output "efs_dns_name" {
  value = aws_efs_file_system.JenkinsEFS.dns_name
}

# Configure Listeners for ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.jenkinsalb.arn
  port              = var.alb_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# Provides Load balancer with a listener rule resource
resource "aws_lb_listener_rule" "asg" {
  # The ARN of the listener to which to attach the rule.
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    # Optional - List of paths to match
    path_pattern {
      values = ["*"]
    }
  }

  action {
    # The type of routing action. 
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

# Output
output "alb_dns_name" {
  value       = aws_lb.jenkinsalb.dns_name
  description = "The domain name of the load balancer"
}
