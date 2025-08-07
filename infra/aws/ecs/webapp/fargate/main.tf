resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-fargate-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.vpc_name}-task-${var.app_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.execution_role_arn
  runtime_platform {
    cpu_architecture = var.cpu_architecture
  }

  container_definitions = jsonencode([{
    name  = var.app_name
    image = var.ecr_repo_url
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
      protocol      = "tcp"
    }]
    environment = [
      {
        name = "DB_HOST"
        value = var.db_host
      },
      {
        name = "DB_PORT"
        value = "5432"
      },
      {
        name = "DB_NAME"
        value = "postgres"
      },
      {
        name = "DB_USER"
        value = "postgres"
      },
      {
        name = "DB_PASSWORD"
        value = "mypasswd"
      },
    ]
  }])
}

resource "aws_ecs_service" "app" {
  name            = "${var.vpc_name}-svc-ecs-fargate"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
    security_groups  = var.task_sg_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.app_name
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http]
}

## ALB
resource "aws_lb" "app" {
  name               = "${var.vpc_name}-alb-ecs"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg_ids
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.vpc_name}-tg-${var.app_name}-ecs"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "5000"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
