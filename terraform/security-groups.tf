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

resource "aws_security_group_rule" "client_service_allow_9090" {
  security_group_id        = aws_security_group.client_service_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9090
  to_port                  = 9090
  source_security_group_id = aws_security_group.my_alb_sg.id
  description              = "Allow Traffic from ALB on Port 9090"
}

resource "aws_security_group_rule" "client_service_allow_self" {
  security_group_id = aws_security_group.client_service_sg.id
  type              = "ingress"
  protocol          = -1
  self              = true
  from_port         = 0
  to_port           = 0
  description       = "Allow traffic from resources with this security group."
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

resource "aws_security_group" "private_fruits_alb_sg" {
  name        = "${var.project}-private-fruits-alb-sg"
  description = "Security Group for Private Fruits ALB Service."
  vpc_id      = aws_vpc.my-vpc.id
}

resource "aws_security_group_rule" "private_fruits_alb_allow_80" {
  security_group_id        = aws_security_group.private_fruits_alb_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.client_service_sg.id
  description              = "Allow Traffic on Port 80 from ECS Client Service SG"
}

resource "aws_security_group_rule" "private_fruits_alb_allow_egress" {
  security_group_id = aws_security_group.private_fruits_alb_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow All Outbound Traffic."
}


resource "aws_security_group" "private_veggie_alb_sg" {
  name        = "${var.project}-private-veggie-alb-sg"
  description = "Security Group for Private Veggie ALB Service."
  vpc_id      = aws_vpc.my-vpc.id
}

resource "aws_security_group_rule" "private_veggie_alb_allow_80" {
  security_group_id        = aws_security_group.private_veggie_alb_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.client_service_sg.id
  description              = "Allow Traffic on Port 80 from ECS Client Service SG"
}

resource "aws_security_group_rule" "private_veggie_alb_allow_egress" {
  security_group_id = aws_security_group.private_veggie_alb_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow All Outbound Traffic."
}


resource "aws_security_group" "private_fruits_service_sg" {
  name        = "${var.project}-private-fruits-service-sg"
  description = "Security Group for Private Fruits Service."
  vpc_id      = aws_vpc.my-vpc.id
}

resource "aws_security_group_rule" "private_fruits_service_allow_9090" {
  security_group_id        = aws_security_group.private_fruits_service_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9090
  to_port                  = 9090
  source_security_group_id = aws_security_group.private_fruits_alb_sg.id
  description              = "Allow Traffic on Port 9090 from Private ALB SG"
}

resource "aws_security_group_rule" "private_fruits_service_allow_self" {
  security_group_id = aws_security_group.private_fruits_service_sg.id
  type              = "ingress"
  protocol          = -1
  self              = true
  from_port         = 0
  to_port           = 0
  description       = "Allow Traffic from resources within security group"
}


resource "aws_security_group_rule" "private_fruits_service_allow_egress" {
  security_group_id = aws_security_group.private_fruits_service_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow All Outbound Traffic."
}

resource "aws_security_group" "private_veggie_service_sg" {
  name        = "${var.project}-private-veggie-service-sg"
  description = "Security Group for Private Veggie Service."
  vpc_id      = aws_vpc.my-vpc.id
}

resource "aws_security_group_rule" "private_veggie_service_allow_9090" {
  security_group_id        = aws_security_group.private_veggie_service_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9090
  to_port                  = 9090
  source_security_group_id = aws_security_group.private_veggie_alb_sg.id
  description              = "Allow Traffic on Port 9090 from Private ALB SG"
}

resource "aws_security_group_rule" "private_veggie_service_allow_self" {
  security_group_id = aws_security_group.private_veggie_service_sg.id
  type              = "ingress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  self              = true
  description       = "Allow Traffic from resources within security group"
}


resource "aws_security_group_rule" "private_veggie_service_allow_egress" {
  security_group_id = aws_security_group.private_veggie_service_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow All Outbound Traffic."
}

resource "aws_security_group" "private-databases-sg" {
  name        = "${var.project}-private-database-sg"
  description = "Security Group for Private Database."
  vpc_id      = aws_vpc.my-vpc.id
}

resource "aws_security_group_rule" "private-databases-sg-veggie-27017" {
  security_group_id        = aws_security_group.private-databases-sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 27017
  to_port                  = 27017
  source_security_group_id = aws_security_group.private_veggie_service_sg.id
  description              = "Allow Traffic on Port 27017 from Veggie Service"
}

resource "aws_security_group_rule" "private-databases-sg-fruits-27017" {
  security_group_id        = aws_security_group.private-databases-sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 27017
  to_port                  = 27017
  source_security_group_id = aws_security_group.private_fruits_service_sg.id
  description              = "Allow Traffic on Port 27017 from Fruits Service"
}

resource "aws_security_group_rule" "private-databases-sg-allow_egress" {
  security_group_id = aws_security_group.private-databases-sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow All Outbound Traffic."
}

