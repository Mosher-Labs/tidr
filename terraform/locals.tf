locals {
  name            = "${var.config.org_name}_${var.config.project_name}"
  hyphenated_name = replace(local.name, "_", "-")
}
