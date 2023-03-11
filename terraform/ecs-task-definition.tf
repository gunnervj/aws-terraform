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
        },
        {
          name  = "UPSTREAM_URIS"
          value = "http://${aws_lb.my-fruits-alb.dns_name},http://${aws_lb.my-veggie-alb.dns_name}"
        }
      ]
    }
  ])
}


resource "aws_ecs_task_definition" "fruits-tdef" {
  family                   = "${var.project}-fruits-tdef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  container_definitions = jsonencode([
    {
      name      = "fruits-service"
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
          value = "fruits-service"
        },
        {
          name  = "MESSAGE"
          value = "Hello from the Fruit Service."
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "veggie-tdef" {
  family                   = "${var.project}-veggie-tdef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  container_definitions = jsonencode([
    {
      name      = "veggie-service"
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
          value = "veggie-service"
        },
        {
          name  = "MESSAGE"
          value = "Hello from the Veggie Service."
        }
      ]
    }
  ])
}