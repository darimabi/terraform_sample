resource "aws_ecs_cluster" "ecs_cluster" {
  name               = "sample-ecs-cluster"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "sample_service" {
  name                               = "sample-ECS-service"
  cluster                            = aws_ecs_cluster.ecs_cluster.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds  = 300
  enable_ecs_managed_tags            = false
  platform_version                   = "LATEST"
  scheduling_strategy                = "REPLICA"
  depends_on                         = [aws_lb_target_group.sample_tg, aws_lb.sample_alb]
  force_new_deployment               = true

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.sample.family}:${max("${aws_ecs_task_definition.sample.revision}", "${aws_ecs_task_definition.sample.revision}")}"

  deployment_controller {
    type = "ECS"
  }
  network_configuration {
    security_groups  = [aws_security_group.ecs_task_sg.id]
    subnets          = data.aws_subnet_ids.private.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sample_tg.id
    container_name   = "sample-container"
    container_port   = 80
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

resource "aws_ecs_task_definition" "sample" {
  family                   = "sample-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "cpu": 128,
    "memory": 512,
    "name": "sample-container",
    "image": "public.ecr.aws/nginx/nginx:latest",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}