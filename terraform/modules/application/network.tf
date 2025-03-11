resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = var.config.name
  }
}

resource "aws_subnet" "public" {
  cidr_block              = "10.0.1.0/24"
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
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.config.name}_ecs"
  }
}

resource "aws_security_group_rule" "ecs_ingress" {
  # cidr_blocks       = [aws_vpc.this.cidr_block]
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs.id
  to_port           = 80
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
