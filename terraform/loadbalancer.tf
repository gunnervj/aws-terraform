resource "aws_lb" "my-alb" {
  name               = "${var.project}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_alb_sg.id]
  subnets            = aws_subnet.my-public-subnet.*.id
  idle_timeout       = 60
  ip_address_type    = "dualstack"

  tags = {
    "Name" = "${var.project}-alb"
  }
}

resource "aws_lb_target_group" "my-alb-client-tg" {
  name        = "${var.project}-alb-tg"
  port        = 9090
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
    target_group_arn = aws_lb_target_group.my-alb-client-tg.arn
  }

  tags = {
    "Name" = "${var.project}-alb_listener_http"
  }

}


resource "aws_lb" "my-fruits-alb" {
  name               = "${var.project}-fruits-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_fruits_alb_sg.id]
  subnets            = [for subnet in aws_subnet.my-private-subnet : subnet.id]
  idle_timeout       = 60

  tags = {
    "Name" = "${var.project}-alb"
  }
}


resource "aws_lb_target_group" "my-fruits-alb-tg" {
  name        = "${var.project}-fruits-alb-tg"
  port        = 9090
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
    "Name" = "${var.project}-fruits-alb-tg"
  }
}

resource "aws_lb_listener" "my-fruits-alb-http_80" {
  load_balancer_arn = aws_lb.my-fruits-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-fruits-alb-tg.arn
  }

  tags = {
    "Name" = "${var.project}_fruits_alb_listener_http"
  }

}

resource "aws_lb" "my-veggie-alb" {
  name               = "${var.project}-veggie-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_veggie_alb_sg.id]
  subnets            = [for subnet in aws_subnet.my-private-subnet : subnet.id]
  idle_timeout       = 60

  tags = {
    "Name" = "${var.project}-veggie-alb"
  }
}


resource "aws_lb_target_group" "my-veggie-alb-tg" {
  name        = "${var.project}-veggie-alb-tg"
  port        = 9090
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
    "Name" = "${var.project}-veggie-alb-tg"
  }
}

resource "aws_lb_listener" "my-veggie-alb-http_80" {
  load_balancer_arn = aws_lb.my-veggie-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-veggie-alb-tg.arn
  }

  tags = {
    "Name" = "${var.project}_veggie_alb_listener_http"
  }

}

output "public_alb_hostname" {
  description = "Host for Public Application Load Balancer"
  value       = aws_lb.my-alb.dns_name
}

resource "aws_lb" "consul_server_alb" {
  name_prefix        = "cs-"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.consul_server_alb_sg.id]
  subnets            = aws_subnet.my-public-subnet.*.id
  idle_timeout       = 60
  ip_address_type    = "dualstack"

  tags = {
    "Name" = "${var.project}_consul_server_alb"
  }
}

resource "aws_lb_target_group" "consul_server_alb_targets" {
  name_prefix          = "cs-"
  port                 = 8500
  protocol             = "HTTP"
  vpc_id               = aws_vpc.my-vpc.id
  deregistration_delay = 30
  target_type          = "instance"

  health_check {
    enabled             = true
    path                = "/v1/status/leader"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    protocol            = "HTTP"
  }
  tags = {
    "Name" = "${var.project}_consul_server_tg"
  }
}

resource "aws_lb_target_group_attachment" "consul_server" {
  count            = var.consul_server_count
  target_group_arn = aws_lb_target_group.consul_server_alb_targets.arn
  target_id        = aws_instance.consul-server[count.index].id
  port             = 8500
}

resource "aws_lb_listener" "consul_server_alb_http_80" {
  load_balancer_arn = aws_lb.consul_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_server_alb_targets.arn
  }
}