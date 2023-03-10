# ECS Cluster
resource "aws_ecs_cluster" "my-ecs-cluster" {
  name = "${var.project}-ecs-cluster"
}

