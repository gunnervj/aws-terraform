resource "aws_ecs_service" "client-service" {
  name            = "${var.project}-client-service"
  cluster         = aws_ecs_cluster.my-ecs-cluster.arn
  task_definition = aws_ecs_task_definition.client-tdef.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.my-alb-client-tg.arn
    container_name   = "client-service"
    container_port   = 9090
  }

  network_configuration {
    subnets          = aws_subnet.my-private-subnet.*.id
    assign_public_ip = false
    security_groups  = [aws_security_group.client_service_sg.id]
  }
}

resource "aws_ecs_service" "fruits-service" {
  name            = "${var.project}-fruits-service"
  cluster         = aws_ecs_cluster.my-ecs-cluster.arn
  task_definition = aws_ecs_task_definition.fruits-tdef.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.my-fruits-alb-tg.arn
    container_name   = "fruits-service"
    container_port   = 9090
  }

  network_configuration {
    subnets          = aws_subnet.my-private-subnet.*.id
    assign_public_ip = false
    security_groups  = [aws_security_group.private_fruits_service_sg.id]
  }

  depends_on = [
    aws_instance.database
  ]
}


resource "aws_ecs_service" "veggie-service" {
  name            = "${var.project}-veggie-service"
  cluster         = aws_ecs_cluster.my-ecs-cluster.arn
  task_definition = aws_ecs_task_definition.veggie-tdef.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.my-veggie-alb-tg.arn
    container_name   = "veggie-service"
    container_port   = 9090
  }

  network_configuration {
    subnets          = aws_subnet.my-private-subnet.*.id
    assign_public_ip = false
    security_groups  = [aws_security_group.private_veggie_service_sg.id]
  }
  
  depends_on = [
    aws_instance.database
  ]
}