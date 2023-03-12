# ECS Cluster
resource "aws_ecs_cluster" "my-ecs-cluster" {
  name = "${var.project}-ecs-cluster"
  depends_on = [
    aws_nat_gateway.my_nat_gateway
  ]
}

