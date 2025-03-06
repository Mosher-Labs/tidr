locals {
  name = var.config.name != null ? "${var.config.name}_" : ""
}
