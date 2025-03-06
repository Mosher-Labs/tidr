resource "aws_iam_policy" "requisite_permissions" {
  name        = "${var.config.name}_requisite_permissions"
  description = "Permissions for read only access."
  policy      = data.aws_iam_policy_document.requisite_permissions.json
}

resource "aws_iam_policy_attachment" "requisite_permissions" {
  name       = "${var.config.name}_requisite_permissions"
  policy_arn = aws_iam_policy.requisite_permissions.arn
  users = [
    "z_terraform"
  ]
}

resource "aws_iam_policy_attachment" "aws_managed_read_only_access" {
  name       = "${var.config.name}_aws_managed_read_only_access"
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  users = [
    "z_terraform"
  ]
}

resource "aws_iam_policy" "state_storage" {
  name        = "${var.config.name}_state_storage"
  description = "Permissions for Terraform state storage management."
  policy      = data.aws_iam_policy_document.state_storage.json
}

resource "aws_iam_policy_attachment" "state_storage" {
  name       = "${var.config.name}_state_storage"
  policy_arn = aws_iam_policy.state_storage.arn
  users = [
    "z_terraform"
  ]
}

