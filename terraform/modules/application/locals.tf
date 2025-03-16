locals {
  hyphenated_name = replace(var.config.name, "_", "-")
  sorted_azs      = sort(data.aws_availability_zones.available.names)
}
