resource "aws_ecs_task_definition" "client-tdef" {
  family                   = "${var.project}-client-tdef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  container_definitions = jsonencode([
    {
      name      = "client-service"
      image     = "nicholasjackson/fake-service:v0.23.1"
      cpu       = 0
      essential = true

      portMappings = [
        {
          containerPort = 9090
          hostPort      = 9090
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NAME"
          value = "client"
        },
        {
          name  = "MESSAGE"
          value = "Hello from the Service."
        }
      ]
    }
  ])
}