resource "aws_iam_role" "ecs_task_execution_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
  name               = "${local.name}ecs_task_execution_role"
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_policy" {
  name       = "${local.name}ecs_task_execution_role_policy"
  policy_arn = data.aws_iam_policy.amazon_ecs_task_execution_role_policy.arn
  roles = [
    aws_iam_role.ecs_task_execution_role.name
  ]
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy" "amazon_ecs_task_execution_role_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}
