resource "aws_security_group" "my_alb_sg" {
  name_prefix = "${var.project}-my-alb-sg"
  description = "Security Group for My Application Load Balancer"
  vpc_id      = aws_vpc.my-vpc.id
}

resource "aws_security_group_rule" "my_alb_allow_80" {
  security_group_id = aws_security_group.my_alb_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow HTTP Traffic."
}

resource "aws_security_group_rule" "my_alb_allow_egress" {
  security_group_id = aws_security_group.my_alb_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow All Outbound Traffic."
}

resource "aws_security_group" "client_service_sg" {
  name_prefix = "${var.project}-ecs-client-service-sg"
  description = "Security Group for ECS Client Service."
  vpc_id      = aws_vpc.my-vpc.id
}


resource "aws_security_group_rule" "client_service_allow_80" {
  security_group_id        = aws_security_group.client_service_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9090
  to_port                  = 9090
  source_security_group_id = aws_security_group.my_alb_sg.id
  description              = "Allow Traffic from ALB on Port 9090"
}

resource "aws_security_group_rule" "client_service_allow_egress" {
  security_group_id = aws_security_group.client_service_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow All Outbound Traffic."
}