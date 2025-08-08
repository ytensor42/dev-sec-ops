variable "vpc_name" {}
variable "app_name" {}
variable "public_zone_name" {}
variable "cpu" { default = "1024" }
variable "memory" { default = "2048" }
variable "cpu_architecture" { default = "X86_64" }    # X86_64, ARM64
variable "container" {}
variable "container_port" { default = 5000 }
variable "certificate_arn" {}
variable "service_sg_ids" {}
variable "alb_sg_ids" {}

module "vpc" {
  source = "git@github.com:ytensor42/dev-sec-ops.git//tf-modules/aws/data/vpc"
  vpc_name = var.vpc_name
}

data "aws_route53_zone" "zone" {
  name = var.public_zone_name
}

# ECS execution role
resource "aws_iam_role" "exec_role" {
  name = "${var.app_name}-ECSTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-fargate-cluster"
}

# ECS task definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.vpc_name}-task-${var.app_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"
  execution_role_arn       = aws_iam_role.exec_role.arn
  runtime_platform {
    cpu_architecture = var.cpu_architecture
  }
  container_definitions = jsonencode(var.container)
}

# ECS service
resource "aws_ecs_service" "app" {
  name            = "${var.vpc_name}-svc-ecs-fargate"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = module.vpc.private_subnet_ids
    assign_public_ip = false
    security_groups  = var.service_sg_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  depends_on = [aws_iam_role.exec_role]
}

# ALB
resource "aws_lb" "app" {
  name               = "${var.vpc_name}-alb-${var.app_name}-ecs"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg_ids
  subnets            = module.vpc.public_subnet_ids
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.vpc_name}-tg-${var.app_name}-ecs"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "${var.container_port}"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_route53_record" "alb_dns" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${var.app_name}.${data.aws_route53_zone.zone.name}"
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
  depends_on = [ data.aws_route53_zone.zone ]
}
