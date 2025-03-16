resource "aws_ecs_cluster" "this" {
  name = var.config.name

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

resource "aws_ecs_service" "this" {
  cluster                 = aws_ecs_cluster.this.id
  desired_count           = 1
  enable_ecs_managed_tags = true
  enable_execute_command  = true
  launch_type             = "FARGATE"
  name                    = var.config.name
  propagate_tags          = "SERVICE"
  task_definition         = aws_ecs_task_definition.this.arn

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs.id]
    subnets          = aws_subnet.public[*].id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = var.config.name
    container_port   = 3000
  }

  tags = {
    Name = var.config.name
  }

  depends_on = [
    aws_iam_role.ecs_task_execution,
  ]
}

resource "aws_ecs_task_definition" "this" {
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  family                   = var.config.name
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task_execution.arn

  # container_definitions = jsonencode(templatefile("${path.module}/task-definitions/task-definition.json.tftpl", {
  #   name = var.config.name
  # }))
  container_definitions = jsonencode([
    {
      cpu       = 256
      essential = true
      image     = "benniemosher/rails-hello-world:latest"
      memory    = 512
      name      = var.config.name
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
      }]
      environment = [
        {
          name  = "RAILS_ENV"
          value = "production"
        },
        {
          name  = "APP_IP_ADDRESS"
          value = aws_lb.ecs.dns_name
        }
      ]
      secrets = [{
        name      = "RAILS_MASTER_KEY"
        valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.config.name}/rails_master_key"
      }]
    }
  ])

  tags = {
    Name = var.config.name
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution.json
  name               = "${var.config.name}_ecs_task_execution"

  tags = {
    Name = "${var.config.name}_ecs_task_execution"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution.name
}

resource "aws_iam_policy" "s3" {
  name        = "${var.config.name}_s3"
  description = "Least privilege policy to access specific S3 bucket"
  policy      = data.aws_iam_policy_document.s3.json

  tags = {
    Name = "${var.config.name}_s3"
  }
}

resource "aws_iam_policy" "dynamodb" {
  name        = "${var.config.name}_dynamodb"
  description = "Least privilege policy to access specific DynamoDB table"
  policy      = data.aws_iam_policy_document.dynamodb.json

  tags = {
    Name = "${var.config.name}_dynamodb"
  }
}

resource "aws_iam_policy_attachment" "s3" {
  name       = "${var.config.name}_s3"
  policy_arn = aws_iam_policy.s3.arn
  roles = [
    aws_iam_role.lambda_execution.name
  ]
}

resource "aws_iam_policy_attachment" "dynamodb" {
  name       = "${var.config.name}_dynamodb"
  policy_arn = aws_iam_policy.dynamodb.arn
  roles = [
    aws_iam_role.lambda_execution.name
  ]
}

resource "aws_iam_policy" "ssm" {
  name        = "${var.config.name}_ssm"
  description = "Allow access to retrieve secrets from SSM"
  policy      = data.aws_iam_policy_document.ssm.json
}

resource "aws_iam_policy_attachment" "ssm" {
  name       = "${var.config.name}_ssm"
  roles      = [aws_iam_role.ecs_task_execution.name]
  policy_arn = aws_iam_policy.ssm.arn
}
