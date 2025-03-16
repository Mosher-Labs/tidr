resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.config.name
  }
}

resource "aws_subnet" "public" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${var.config.name}_public"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.config.name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.config.name}_public"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  route_table_id         = aws_route_table.public.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.config.name}_ecs"
  }
}

# resource "aws_security_group_rule" "ecs_ingress" {
#   # cidr_blocks       = [aws_vpc.this.cidr_block]
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 3000
#   protocol          = "tcp"
#   security_group_id = aws_security_group.ecs.id
#   to_port           = 3000
#   type              = "ingress"
# }

resource "aws_security_group_rule" "ecs_ingress_http" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "ecs_ingress_https" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "ecs_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs.id
  to_port           = 0
  type              = "egress"
}

resource "aws_lb" "ecs" {
  internal           = false
  load_balancer_type = "application"
  name               = local.hyphenated_name
  security_groups    = [aws_security_group.ecs.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "ecs" {
  name        = local.hyphenated_name
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.this.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  certificate_arn   = data.aws_acm_certificate.this.arn
  load_balancer_arn = aws_lb.ecs.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_lb_target_group.ecs.arn
    type             = "forward"
  }
}

resource "aws_security_group" "lambda" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.config.name}_lambda"
  }
}

resource "aws_security_group_rule" "lambda_egress" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lambda.id
  to_port           = 0
  type              = "egress"
}
