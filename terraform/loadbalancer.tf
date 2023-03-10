resource "aws_lb" "my-alb" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_alb_sg.id]
  subnets            = [for subnet in aws_subnet.my-public-subnet : subnet.id]

  enable_deletion_protection = false

  tags = {
    "Name" = "${var.project}-alb"
  }
}

resource "aws_lb_target_group" "my-alb-tg" {
  name        = "${var.project}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my-vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    protocol            = "HTTP"
  }

  tags = {
    "Name" = "${var.project}-alb-tg"
  }
}

resource "aws_lb_listener" "my-alb-http_80" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-alb-tg.arn
  }

  tags = {
    "Name" = "${var.project}-alb_listener_http"
  }

}

output "alb_hostname" {
  description = "Host for Application Load Balancer"
  value       = aws_lb.my-alb.dns_name
}

