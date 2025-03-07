variable "aws_config" {
  description = "The AWS config to deploy resources with."
  type = object({
    region = optional(string, "us-west-2")
  })
}

variable "config" {
  description = "The configuration for the application."
  type = object({
    org_name     = optional(string, "mosher_labs")
    project_name = string
  })
}
