resource "aws_ecs_service" "client-service" {
  name            = "${var.project}-client-service"
  cluster         = aws_ecs_cluster.my-ecs-cluster.arn
  task_definition = aws_ecs_task_definition.client-tdef.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.my-alb-tg.arn
    container_name   = "client-service"
    container_port   = 9090
  }

  network_configuration {
    subnets          = aws_subnet.my-public-subnet.*.id
    assign_public_ip = true
    security_groups  = [aws_security_group.client_service_sg.id]
  }
}