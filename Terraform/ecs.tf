# ECS Cluster
resource "aws_ecs_cluster" "aws_ecs_cluster" {
  name = "${var.app_name}-${var.app_environment}-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "aws_ecs_task" {
  family                   = "${var.app_name}-${var.app_environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn      = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.app_name}-${var.app_environment}-container",
    "image": "${aws_ecr_repository.aws_ecr.repository_url}:${var.image_tag}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}

# ECS Service
resource "aws_ecs_service" "aws_ecs_service" {
  name            = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster         = aws_ecs_cluster.aws_ecs_cluster.id
  task_definition = "${aws_ecs_task_definition.aws_ecs_task.family}:${aws_ecs_task_definition.aws_ecs_task.revision}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.public_subnets
    security_groups = [aws_security_group.service_security_group.id, aws_security_group.load_balancer_security_group.id]
    assign_public_ip = true
  }
}