resource "aws_iam_role" "ecs_task_execution" {
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution.json
  name               = "${var.config.name}_ecs_task_execution"
}

resource "aws_iam_policy_attachment" "ecs_task_execution" {
  name       = "${var.config.name}_ecs_task_execution"
  policy_arn = data.aws_iam_policy.amazon_ecs_task_execution.arn
  roles = [
    aws_iam_role.ecs_task_execution.name
  ]
}

